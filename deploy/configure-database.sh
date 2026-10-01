#!/usr/bin/env bash
# Run once with sudo from the reviewed feature checkout before its first deployment.
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run as root' >&2; exit 1; }
[[ $# == 0 ]] || { echo 'No arguments expected' >&2; exit 2; }
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
stack=/opt/dancehall
exec 9>"$stack/deploy.lock"
flock -w 600 9
cd "$stack"
compose=(docker compose --project-name dancehall --file "$stack/compose.yaml")
# Verify the existing application role and secret without printing the password.
"${compose[@]}" exec -T postgres bash -ec '
  export PGPASSWORD=$(cat /run/secrets/app_password)
  psql -h 127.0.0.1 -U dancehall -d dancehall -v ON_ERROR_STOP=1 \
    -c "SELECT current_user, current_database();"
'
/usr/local/sbin/dancehall-backup
install -m 0644 "$source_dir/compose.yaml" "$stack/compose.database.next.yaml"
export BACKEND_IMAGE
BACKEND_IMAGE=$(cat "$stack/current-image")
docker compose --project-name dancehall --project-directory "$stack" \
  --file "$stack/compose.database.next.yaml" config --quiet
cp "$stack/compose.yaml" "$stack/compose.before-database.yaml"
mv "$stack/compose.database.next.yaml" "$stack/compose.yaml"
echo 'Database configuration ready. The next backend deployment will apply it.'
