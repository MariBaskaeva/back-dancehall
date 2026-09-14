#!/usr/bin/env bash
# Installed root-owned; the deployment user can invoke only this sudo command.
set -Eeuo pipefail
STACK_DIR=/opt/dancehall
INCOMING_DIR=/home/dancehall-deploy/incoming
PROJECT_NAME=dancehall
HEALTH_URL=https://87.242.119.237/api/ping
HEALTH_TIMEOUT=120

revision=${1:-}
[[ $# == 1 && "$revision" =~ ^[0-9a-f]{40}$ ]] || { echo 'Expected one full commit SHA' >&2; exit 2; }
cd "$STACK_DIR"
exec 9>"$STACK_DIR/deploy.lock"
flock -w 600 9 || { echo 'Another deployment is running' >&2; exit 1; }
compose=(docker compose --project-name "$PROJECT_NAME" --file "$STACK_DIR/compose.yaml")
image="dancehall-backend:$revision"
previous=$(cat "$STACK_DIR/current-image" 2>/dev/null || true)
previous_previous=$(cat "$STACK_DIR/previous-image" 2>/dev/null || true)
for saved in "$previous" "$previous_previous"; do
  [[ -z "$saved" || "$saved" =~ ^dancehall-backend:[0-9a-f]{40}$ ]] || exit 2
done
bundle="$INCOMING_DIR/$revision"
# Do not deploy an obsolete queued run after a newer commit reaches main.
latest=$(git ls-remote https://github.com/MariBaskaeva/back-dancehall.git refs/heads/main \
  | awk '{print $1}')
[[ "$latest" =~ ^[0-9a-f]{40}$ ]] || { echo 'Cannot resolve current main revision' >&2; exit 1; }
if [[ "$latest" != "$revision" ]]; then
  echo "Skipping obsolete revision $revision; main is $latest"
  exit 0
fi
# Use a fixed checksum filename instead of interpreting a transferred checksum file as paths.
expected=$(awk '{print $1}' "$bundle/image.tar.gz.sha256")
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || exit 2
actual=$(sha256sum "$bundle/image.tar.gz" | awk '{print $1}')
[[ "$expected" == "$actual" ]] || { echo 'Image archive checksum mismatch' >&2; exit 1; }
docker image load --input "$bundle/image.tar.gz"
expected_id=$(cat "$bundle/image-id.txt")
[[ "$expected_id" =~ ^sha256:[0-9a-f]{64}$ ]] || exit 2
actual_id=$(docker image inspect --format '{{.Id}}' "$image")
# With Docker's containerd image store, inspect can report the OCI manifest digest
# after load instead of the config digest reported before save. Both are bound to
# the verified archive, so accept either representation.
archive_ids=$(tar -xOzf "$bundle/image.tar.gz" index.json \
  | grep -oE '"digest":"sha256:[0-9a-f]{64}"' | cut -d'"' -f4)
[[ -n "$archive_ids" ]] || exit 2
if [[ "$actual_id" != "$expected_id" ]] \
    && ! grep -Fxq "$actual_id" <<< "$archive_ids"; then
  echo "Loaded image ID mismatch: expected $expected_id or an OCI archive digest, got $actual_id" >&2
  exit 1
fi
[[ $(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$image") == "$revision" ]] || exit 1

check_health() {
  local deadline=$((SECONDS + HEALTH_TIMEOUT)) container_id status response
  while (( SECONDS < deadline )); do
    container_id=$("${compose[@]}" ps -q backend 2>/dev/null || true)
    status=$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' "$container_id" 2>/dev/null || true)
    if [[ "$status" == healthy ]]; then
      response=$(curl --fail --silent --show-error --max-time 5 \
        --write-out '\n%{http_code}\n%{content_type}' "$HEALTH_URL" 2>/dev/null || true)
      if [[ "$response" == $'pong\n200\ntext/plain'* ]]; then return 0; fi
    fi
    sleep 2
  done
  return 1
}

changed=false
rollback() {
  local code=$?
  trap - EXIT HUP INT TERM
  if [[ "$changed" == true ]]; then
    echo 'Deployment failed; restoring the previous backend' >&2
    "${compose[@]}" logs --tail 80 backend >&2 || true
    if [[ -n "$previous" ]]; then
      export BACKEND_IMAGE="$previous"
      if "${compose[@]}" up -d --no-deps backend && check_health; then
        echo "Rollback succeeded: $previous" >&2
      else
        echo 'ROLLBACK FAILED: manual recovery is required' >&2
      fi
    else
      "${compose[@]}" stop backend || true
      echo 'First deployment failed; no previous image exists' >&2
    fi
  fi
  exit "${code:-1}"
}
trap rollback EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
export BACKEND_IMAGE="$image"
changed=true
"${compose[@]}" up -d --no-deps backend
check_health
# Commit state only after both container health and the public endpoint pass.
printf '%s\n' "$image" > "$STACK_DIR/current-image.next"
mv "$STACK_DIR/current-image.next" "$STACK_DIR/current-image"
if [[ -n "$previous" && "$previous" != "$image" ]]; then
  printf '%s\n' "$previous" > "$STACK_DIR/previous-image.next"
  mv "$STACK_DIR/previous-image.next" "$STACK_DIR/previous-image"
fi
changed=false
trap - EXIT HUP INT TERM
# Cleanup is limited to this project's archives and tagged backend images.
keep_previous=$(cat "$STACK_DIR/previous-image" 2>/dev/null || true)
while IFS= read -r candidate; do
  if [[ "$candidate" != "$image" && "$candidate" != "$keep_previous" ]]; then
    docker image rm "$candidate" || true
  fi
done < <(docker image ls --format '{{.Repository}}:{{.Tag}}' dancehall-backend)
find "$INCOMING_DIR" -mindepth 2 -maxdepth 2 -type f \
  \( -name image.tar.gz -o -name image.tar.gz.sha256 -o -name image-id.txt \) -mmin +60 -delete
find "$INCOMING_DIR" -mindepth 1 -maxdepth 1 -type d -empty -delete
printf 'Deployed %s\n' "$image"
