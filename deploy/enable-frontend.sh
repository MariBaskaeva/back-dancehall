#!/usr/bin/env bash
# Run once with sudo from a reviewed backend checkout on the existing VPS.
set -Eeuo pipefail

[[ $EUID == 0 ]] || {
  echo 'Run as root' >&2
  exit 1
}

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
stack=/opt/dancehall
compose=$stack/compose.yaml
active_nginx=$stack/nginx/default.conf
template_nginx=$stack/templates/nginx-https.conf
sudoers=/etc/sudoers.d/dancehall-deploy

[[ -f "$compose" && -f "$active_nginx" ]] || {
  echo 'The existing Dancehall stack is not installed' >&2
  exit 2
}
[[ -s "$stack/certificates/live/87.242.119.237/fullchain.pem" ]] || {
  echo 'The production TLS certificate is not installed' >&2
  exit 2
}
id dancehall-deploy >/dev/null 2>&1 || {
  echo 'The dancehall-deploy user does not exist' >&2
  exit 2
}

for required in compose.yaml nginx-https.conf deploy-frontend.sh; do
  [[ -f "$source_dir/$required" ]] || {
    echo "Missing setup source: $required" >&2
    exit 2
  }
done

install -d -m 0755 "$stack/frontend" "$stack/frontend/releases"

nginx_image=$(docker compose --file "$compose" config --images | grep '^nginx:')
[[ -n "$nginx_image" ]] || {
  echo 'Cannot resolve the nginx image' >&2
  exit 2
}

docker run --rm --read-only \
  --tmpfs /var/cache/nginx:size=32m --tmpfs /var/run:size=1m \
  -v "$source_dir/nginx-https.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$stack/certificates:/etc/letsencrypt:ro" \
  -v "$stack/frontend:/usr/share/nginx/html:ro" \
  "$nginx_image" nginx -t

backup_dir=$(mktemp -d)
cp "$compose" "$backup_dir/compose.yaml"
cp "$active_nginx" "$backup_dir/default.conf"
cp "$template_nginx" "$backup_dir/nginx-https.conf"
cp "$sudoers" "$backup_dir/dancehall-deploy.sudoers"
changed=false

rollback() {
  local code=$?
  trap - EXIT HUP INT TERM
  if [[ "$changed" == true ]]; then
    echo 'Frontend infrastructure setup failed; restoring nginx configuration' >&2
    install -m 0644 "$backup_dir/compose.yaml" "$compose"
    install -m 0644 "$backup_dir/default.conf" "$active_nginx"
    install -m 0644 "$backup_dir/nginx-https.conf" "$template_nginx"
    install -m 0440 "$backup_dir/dancehall-deploy.sudoers" "$sudoers"
    docker compose --project-name dancehall --file "$compose" \
      up -d --no-deps --force-recreate nginx || true
  fi
  rm -rf -- "$backup_dir"
  exit "${code:-1}"
}
trap rollback EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

install -m 0644 "$source_dir/compose.yaml" "$compose"
install -m 0644 "$source_dir/nginx-https.conf" "$template_nginx"
install -m 0644 "$source_dir/nginx-https.conf" "$active_nginx"
install -m 0755 "$source_dir/deploy-frontend.sh" /usr/local/sbin/dancehall-deploy-frontend
printf '%s\n' \
  'dancehall-deploy ALL=(root) NOPASSWD: /usr/local/sbin/dancehall-deploy' \
  'dancehall-deploy ALL=(root) NOPASSWD: /usr/local/sbin/dancehall-deploy-frontend' \
  > "$sudoers"
chmod 0440 "$sudoers"
visudo -cf "$sudoers"
docker compose --project-name dancehall --file "$compose" config --quiet
changed=true
docker compose --project-name dancehall --file "$compose" \
  up -d --no-deps --force-recreate nginx

for ((attempt=0; attempt<30; attempt++)); do
  api_response=$(curl --fail --silent --show-error --max-time 5 \
    --write-out '\n%{http_code}\n%{content_type}' \
    https://87.242.119.237/api/ping 2>/dev/null || true)
  root_status=$(curl --silent --show-error --max-time 5 --output /dev/null \
    --write-out '%{http_code}' https://87.242.119.237/ 2>/dev/null || true)
  if [[ "$api_response" == $'pong\n200\ntext/plain'* ]] \
    && [[ "$root_status" == 200 || "$root_status" == 404 ]]; then
    changed=false
    trap - EXIT HUP INT TERM
    rm -rf -- "$backup_dir"
    echo 'Frontend infrastructure is ready'
    exit 0
  fi
  sleep 2
done

echo 'Updated nginx did not pass public health checks' >&2
exit 1
