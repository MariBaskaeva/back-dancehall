#!/usr/bin/env bash
set -euo pipefail
image=${1:?Image is required}
name="dancehall-image-test-$$"
network="dancehall-image-test-network-$$"
source deploy/test-database.sh
# ShellCheck cannot see that traps invoke this function.
# shellcheck disable=SC2329
cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  stop_test_database
  docker network rm "$network" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
docker network create "$network" >/dev/null
start_test_database
docker run -d --name "$name" --network "$network" --memory 1g --read-only --tmpfs /tmp:size=64m \
  --cap-drop ALL --security-opt no-new-privileges --init \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/dancehall \
  -e SPRING_DATASOURCE_USERNAME=dancehall -e SPRING_CONFIG_IMPORT=configtree:/run/secrets/ \
  -v "$test_database_dir:/run/secrets:ro" \
  -e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=60.0 -p 127.0.0.1::8080 "$image"
address=$(docker port "$name" 8080/tcp)
for ((attempt=0; attempt<60; attempt++)); do
  response=$(curl --fail --silent --max-time 3 --output /dev/null --write-out '%{http_code}\n%{content_type}' "http://$address/api/v1/authors" || true)
  if [[ "$response" == $'200\napplication/json'* ]]; then
    [[ $(docker image inspect --format '{{.Config.User}}' "$image") == '10001:10001' ]]
    echo 'Container returned 200 application/json from /api/v1/authors'
    exit 0
  fi
  sleep 2
done
docker logs "$name"
exit 1
