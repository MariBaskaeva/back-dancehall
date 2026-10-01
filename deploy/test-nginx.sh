#!/usr/bin/env bash
set -euo pipefail

image=${1:?Image is required}
suffix=$$
backend="dancehall-nginx-test-backend-$suffix"
nginx="dancehall-nginx-test-proxy-$suffix"
network="dancehall-nginx-test-$suffix"
work_dir="target/nginx-test-$suffix"
source deploy/test-database.sh

# ShellCheck cannot see that traps invoke this function.
# shellcheck disable=SC2329
cleanup() {
  docker rm -f "$nginx" "$backend" >/dev/null 2>&1 || true
  stop_test_database
  docker network rm "$network" >/dev/null 2>&1 || true
  rm -rf "$work_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

mkdir -p "$work_dir/certificates/live/87.242.119.237" \
  "$work_dir/frontend/releases/test/assets"
printf '%s\n' '<!doctype html><meta name="dancehall-revision" content="test"><h1>Dancehall</h1>' \
  > "$work_dir/frontend/releases/test/index.html"
printf '%s\n' 'console.log("dancehall")' > "$work_dir/frontend/releases/test/assets/app.js"
ln -s releases/test "$work_dir/frontend/current"
openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
  -subj '/CN=87.242.119.237' -addext 'subjectAltName=IP:87.242.119.237' \
  -keyout "$work_dir/certificates/live/87.242.119.237/privkey.pem" \
  -out "$work_dir/certificates/live/87.242.119.237/fullchain.pem" >/dev/null 2>&1

nginx_image=$(awk '$1 == "image:" && $2 ~ /^nginx:/ {print $2}' deploy/compose.yaml)
[[ -n "$nginx_image" ]]
docker pull "$nginx_image" >/dev/null
docker network create "$network" >/dev/null
start_test_database
docker run -d --name "$backend" --network "$network" --network-alias backend \
  --memory 1g --read-only --tmpfs /tmp:size=64m --cap-drop ALL \
  --security-opt no-new-privileges --init \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/dancehall \
  -e SPRING_DATASOURCE_USERNAME=dancehall -e SPRING_CONFIG_IMPORT=configtree:/run/secrets/ \
  -v "$test_database_dir:/run/secrets:ro" "$image" >/dev/null

for ((attempt=0; attempt<60; attempt++)); do
  if [[ $(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' \
      "$backend") == healthy ]]; then
    break
  fi
  sleep 2
done
[[ $(docker inspect --format '{{.State.Health.Status}}' "$backend") == healthy ]]

docker run -d --name "$nginx" --network "$network" --read-only \
  --tmpfs /var/cache/nginx:size=32m --tmpfs /var/run:size=1m \
  -p 127.0.0.1::443 \
  -v "$PWD/deploy/nginx-https.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$PWD/$work_dir/certificates:/etc/letsencrypt:ro" \
  -v "$PWD/$work_dir/frontend:/usr/share/nginx/html:ro" "$nginx_image" >/dev/null
address=$(docker port "$nginx" 443/tcp)

for ((attempt=0; attempt<30; attempt++)); do
  response=$(curl --insecure --fail --silent --max-time 3 \
    --output /dev/null --write-out '%{http_code}\n%{content_type}' "https://$address/api/v1/authors" || true)
  if [[ "$response" == $'200\napplication/json'* ]]; then
    break
  fi
  sleep 1
done
[[ "$response" == $'200\napplication/json'* ]]

root_response=$(curl --insecure --fail --silent --max-time 3 \
  --write-out '\n%{http_code}\n%{content_type}' "https://$address/" || true)
[[ "$root_response" == *'dancehall-revision'*$'\n200\ntext/html'* ]]

fallback_response=$(curl --insecure --fail --silent --max-time 3 \
  --write-out '\n%{http_code}\n%{content_type}' "https://$address/classes/upcoming" || true)
[[ "$fallback_response" == *'dancehall-revision'*$'\n200\ntext/html'* ]]

asset_headers=$(curl --insecure --fail --silent --max-time 3 \
  --dump-header - --output /dev/null "https://$address/assets/app.js" || true)
grep -Eiq '^content-type: (application|text)/javascript' <<< "$asset_headers"
grep -Eiq '^cache-control: public, max-age=31536000, immutable' <<< "$asset_headers"

index_headers=$(curl --insecure --fail --silent --max-time 3 \
  --dump-header - --output /dev/null "https://$address/index.html" || true)
grep -Eiq '^cache-control: no-cache' <<< "$index_headers"

echo 'nginx served frontend, SPA fallback and backend /api/v1/authors'
