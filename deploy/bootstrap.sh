#!/usr/bin/env bash
# Run with sudo from a reviewed checkout; argument: dedicated deployment public key.
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run as root' >&2; exit 1; }
[[ $# == 1 && -f "$1" ]] || { echo 'Provide the deployment public key file' >&2; exit 2; }
public_key=$(cat "$1")
[[ "$public_key" == ssh-ed25519\ * ]] || exit 2
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
stack=/opt/dancehall
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ca-certificates curl git openssl ufw
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
cat > /etc/apt/sources.list.d/docker.sources <<'APT'
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: jammy
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
APT
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker
id dancehall-deploy >/dev/null 2>&1 || useradd --create-home --shell /bin/bash dancehall-deploy
install -d -o dancehall-deploy -g dancehall-deploy -m 0700 /home/dancehall-deploy/.ssh /home/dancehall-deploy/incoming
printf 'restrict %s\n' "$public_key" > /home/dancehall-deploy/.ssh/authorized_keys
chown dancehall-deploy:dancehall-deploy /home/dancehall-deploy/.ssh/authorized_keys
chmod 0600 /home/dancehall-deploy/.ssh/authorized_keys
install -d -m 0755 "$stack" "$stack/nginx" "$stack/acme" "$stack/templates"
install -d -m 0700 "$stack/secrets" "$stack/certificates" "$stack/backups"
install -d -m 0755 "$stack/frontend" "$stack/frontend/releases"
for file in compose.yaml init-db.sh; do install -m 0644 "$source_dir/$file" "$stack/$file"; done
for file in nginx-http.conf nginx-https.conf; do install -m 0644 "$source_dir/$file" "$stack/templates/$file"; done
for secret in postgres_password app_password; do
  if [[ ! -s "$stack/secrets/$secret" ]]; then
    (umask 077; openssl rand -hex 32 > "$stack/secrets/$secret")
  fi
  # Directory is root-only on the host; PostgreSQL must read the mounted secret.
  chmod 0444 "$stack/secrets/$secret"
done
install -m 0755 "$source_dir/deploy.sh" /usr/local/sbin/dancehall-deploy
install -m 0755 "$source_dir/backup.sh" /usr/local/sbin/dancehall-backup
install -m 0755 "$source_dir/renew-certificate.sh" /usr/local/sbin/dancehall-renew-certificate
install -m 0755 "$source_dir/restore-check.sh" /usr/local/sbin/dancehall-restore-check
install -m 0755 "$source_dir/deploy-frontend.sh" /usr/local/sbin/dancehall-deploy-frontend
printf '%s\n' \
  'dancehall-deploy ALL=(root) NOPASSWD: /usr/local/sbin/dancehall-deploy' \
  'dancehall-deploy ALL=(root) NOPASSWD: /usr/local/sbin/dancehall-deploy-frontend' \
  > /etc/sudoers.d/dancehall-deploy
chmod 0440 /etc/sudoers.d/dancehall-deploy
visudo -cf /etc/sudoers.d/dancehall-deploy
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
cd "$stack"
if [[ -s certificates/live/87.242.119.237/fullchain.pem ]]; then
  install -m 0644 templates/nginx-https.conf nginx/default.conf
else
  install -m 0644 templates/nginx-http.conf nginx/default.conf
fi
docker compose -p dancehall up -d --wait --wait-timeout 120 postgres nginx
if [[ ! -s certificates/live/87.242.119.237/fullchain.pem ]]; then
  cert_args=(certonly --non-interactive --agree-tos --register-unsafely-without-email
    --preferred-profile shortlived --webroot --webroot-path /var/www/certbot
    --ip-address 87.242.119.237 --cert-name 87.242.119.237)
  docker compose -p dancehall run --rm --no-deps certbot "${cert_args[@]}" --dry-run
  docker compose -p dancehall run --rm --no-deps certbot "${cert_args[@]}"
  install -m 0644 templates/nginx-https.conf nginx/default.conf
  docker compose -p dancehall exec -T nginx nginx -t
  docker compose -p dancehall exec -T nginx nginx -s reload
fi
cat > /etc/systemd/system/dancehall-backup.service <<'UNIT'
[Unit]
Description=Back up dancehall PostgreSQL
Requires=docker.service
After=docker.service
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dancehall-backup
UNIT
cat > /etc/systemd/system/dancehall-backup.timer <<'UNIT'
[Unit]
Description=Daily dancehall database backup
[Timer]
OnCalendar=*-*-* 03:00:00 UTC
RandomizedDelaySec=10m
Persistent=true
[Install]
WantedBy=timers.target
UNIT
cat > /etc/systemd/system/dancehall-certificate.service <<'UNIT'
[Unit]
Description=Renew dancehall IP certificate and reload nginx
Requires=docker.service
After=docker.service network-online.target
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/dancehall-renew-certificate
UNIT
cat > /etc/systemd/system/dancehall-certificate.timer <<'UNIT'
[Unit]
Description=Check dancehall certificate renewal every six hours
[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00 UTC
RandomizedDelaySec=10m
Persistent=true
[Install]
WantedBy=timers.target
UNIT
systemctl daemon-reload
systemctl enable --now dancehall-backup.timer dancehall-certificate.timer
/usr/local/sbin/dancehall-backup
latest_backup=$(find "$stack/backups" -maxdepth 1 -type f -name 'dancehall-*.dump' \
  -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)
[[ -n "$latest_backup" ]]
/usr/local/sbin/dancehall-restore-check "$latest_backup"
echo 'Infrastructure ready; backend will start after its first approved main deployment.'
