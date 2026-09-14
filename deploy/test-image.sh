#!/usr/bin/env bash
set -euo pipefail
image=${1:?Image is required}
name="dancehall-image-test-$$"
# ShellCheck cannot see that traps invoke this function.
# shellcheck disable=SC2329
cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
docker run -d --name "$name" --memory 1g --read-only --tmpfs /tmp:size=64m \
  --cap-drop ALL --security-opt no-new-privileges --init \
  -e JAVA_TOOL_OPTIONS=-XX:MaxRAMPercentage=60.0 -p 127.0.0.1::8080 "$image"
address=$(docker port "$name" 8080/tcp)
for ((attempt=0; attempt<60; attempt++)); do
  response=$(curl --fail --silent --max-time 3 --write-out '\n%{http_code}\n%{content_type}' "http://$address/ping" || true)
  if [[ "$response" == $'pong\n200\ntext/plain'* ]]; then
    [[ $(docker image inspect --format '{{.Config.User}}' "$image") == '10001:10001' ]]
    echo 'Container returned 200 text/plain pong'
    exit 0
  fi
  sleep 2
done
docker logs "$name"
exit 1
