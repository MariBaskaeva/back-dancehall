#!/usr/bin/env bash
# Installed root-owned; the deployment user can invoke only this sudo command.
set -Eeuo pipefail

[[ $EUID == 0 ]] || {
  echo 'Run as root' >&2
  exit 1
}

STACK_DIR=/opt/dancehall
FRONTEND_DIR=$STACK_DIR/frontend
RELEASES_DIR=$FRONTEND_DIR/releases
INCOMING_DIR=/home/dancehall-deploy/incoming/frontend
REPOSITORY_URL=https://github.com/MariBaskaeva/front-dancehall.git
HEALTH_URL=https://87.242.119.237/
API_HEALTH_URL=https://87.242.119.237/api/ping
HEALTH_TIMEOUT=60

revision=${1:-}
[[ $# == 1 && "$revision" =~ ^[0-9a-f]{40}$ ]] || {
  echo 'Expected one full commit SHA' >&2
  exit 2
}

bundle=$INCOMING_DIR/$revision
archive=$bundle/frontend.tar.gz
checksum=$bundle/frontend.tar.gz.sha256
release=$RELEASES_DIR/$revision
staging=$RELEASES_DIR/.staging-$revision-$$

[[ -f "$archive" && -f "$checksum" ]] || {
  echo "Frontend bundle is incomplete: $bundle" >&2
  exit 2
}

cd "$STACK_DIR"
exec 9>"$STACK_DIR/deploy.lock"
flock -w 600 9 || {
  echo 'Another deployment is running' >&2
  exit 1
}
rm -f "$FRONTEND_DIR/current.next" "$FRONTEND_DIR/current.rollback" \
  "$FRONTEND_DIR/previous.next"

latest=$(git ls-remote "$REPOSITORY_URL" refs/heads/main | awk '{print $1}')
[[ "$latest" =~ ^[0-9a-f]{40}$ ]] || {
  echo 'Cannot resolve current frontend main revision' >&2
  exit 1
}
if [[ "$latest" != "$revision" ]]; then
  echo "Skipping obsolete frontend revision $revision; main is $latest"
  exit 0
fi

expected=$(awk 'NR == 1 {print $1}' "$checksum")
[[ "$expected" =~ ^[0-9a-f]{64}$ ]] || {
  echo 'Invalid frontend checksum file' >&2
  exit 2
}
actual=$(sha256sum "$archive" | awk '{print $1}')
[[ "$expected" == "$actual" ]] || {
  echo 'Frontend archive checksum mismatch' >&2
  exit 1
}

entry_count=0
while IFS= read -r entry; do
  ((entry_count += 1))
  normalized=${entry#./}
  [[ -z "$normalized" ]] && continue
  case "$normalized" in
    /* | .. | ../* | */../* | */..)
      echo "Unsafe path in frontend archive: $entry" >&2
      exit 2
      ;;
  esac
done < <(tar -tzf "$archive")
((entry_count > 0)) || {
  echo 'Frontend archive is empty' >&2
  exit 2
}

while IFS= read -r listing; do
  case "${listing:0:1}" in
    - | d) ;;
    *)
      echo 'Frontend archive may contain only regular files and directories' >&2
      exit 2
      ;;
  esac
done < <(tar -tvzf "$archive")

check_health() {
  local expected_revision=$1
  local deadline=$((SECONDS + HEALTH_TIMEOUT))
  local html_file response api_response
  html_file=$(mktemp)
  while ((SECONDS < deadline)); do
    response=$(curl --fail --silent --show-error --max-time 5 \
      --output "$html_file" --write-out '%{http_code}\n%{content_type}' "$HEALTH_URL" \
      2>/dev/null || true)
    api_response=$(curl --fail --silent --show-error --max-time 5 \
      --write-out '\n%{http_code}\n%{content_type}' "$API_HEALTH_URL" \
      2>/dev/null || true)
    if [[ "$response" == $'200\ntext/html'* ]] \
      && grep -Fq "name=\"dancehall-revision\" content=\"$expected_revision\"" "$html_file" \
      && [[ "$api_response" == $'pong\n200\ntext/plain'* ]]; then
      rm -f "$html_file"
      return 0
    fi
    sleep 2
  done
  rm -f "$html_file"
  return 1
}

previous=$(readlink "$FRONTEND_DIR/current" 2>/dev/null || true)
[[ -z "$previous" || "$previous" =~ ^releases/[0-9a-f]{40}$ ]] || {
  echo "Invalid current frontend link: $previous" >&2
  exit 2
}

if [[ "$previous" == "releases/$revision" ]]; then
  check_health "$revision"
  echo "Frontend $revision is already deployed"
  exit 0
fi

rm -rf -- "$staging"
install -d -m 0755 "$staging"
changed=false

rollback() {
  local code=$?
  trap - EXIT HUP INT TERM
  rm -rf -- "$staging"
  if [[ "$changed" == true ]]; then
    echo 'Frontend deployment failed; restoring the previous release' >&2
    if [[ -n "$previous" ]]; then
      ln -s "$previous" "$FRONTEND_DIR/current.rollback"
      mv -Tf "$FRONTEND_DIR/current.rollback" "$FRONTEND_DIR/current"
      previous_revision=${previous##*/}
      if check_health "$previous_revision"; then
        echo "Frontend rollback succeeded: $previous_revision" >&2
      else
        echo 'FRONTEND ROLLBACK FAILED: manual recovery is required' >&2
      fi
    else
      rm -f "$FRONTEND_DIR/current"
      echo 'First frontend deployment failed; no previous release exists' >&2
    fi
  fi
  exit "${code:-1}"
}
trap rollback EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

tar --extract --gzip --file "$archive" --directory "$staging" \
  --no-same-owner --no-same-permissions
[[ -f "$staging/index.html" ]] || {
  echo 'Frontend archive does not contain index.html' >&2
  exit 2
}
grep -Fq "name=\"dancehall-revision\" content=\"$revision\"" "$staging/index.html" || {
  echo 'Frontend revision marker does not match the requested revision' >&2
  exit 2
}
find "$staging" -type d -exec chmod 0755 {} +
find "$staging" -type f -exec chmod 0644 {} +

if [[ -e "$release" ]]; then
  rm -rf -- "$release"
fi
mv "$staging" "$release"
ln -s "releases/$revision" "$FRONTEND_DIR/current.next"
mv -Tf "$FRONTEND_DIR/current.next" "$FRONTEND_DIR/current"
changed=true

check_health "$revision"

if [[ -n "$previous" ]]; then
  ln -s "$previous" "$FRONTEND_DIR/previous.next"
  mv -Tf "$FRONTEND_DIR/previous.next" "$FRONTEND_DIR/previous"
else
  rm -f "$FRONTEND_DIR/previous"
fi
changed=false
trap - EXIT HUP INT TERM

keep_previous=$(readlink "$FRONTEND_DIR/previous" 2>/dev/null || true)
shopt -s nullglob
for candidate in "$RELEASES_DIR"/[0-9a-f]*; do
  candidate_revision=${candidate##*/}
  [[ "$candidate_revision" =~ ^[0-9a-f]{40}$ ]] || continue
  candidate_link=releases/$candidate_revision
  if [[ "$candidate_link" != "releases/$revision" && "$candidate_link" != "$keep_previous" ]]; then
    rm -rf -- "$candidate"
  fi
done

find "$INCOMING_DIR" -mindepth 2 -maxdepth 2 -type f \
  \( -name frontend.tar.gz -o -name frontend.tar.gz.sha256 \) -mmin +60 -delete
find "$INCOMING_DIR" -mindepth 1 -maxdepth 1 -type d -empty -delete
printf 'Deployed frontend %s\n' "$revision"
