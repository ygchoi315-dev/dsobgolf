#!/usr/bin/env bash
# DS OB Golf 기록 페이지 서버 설치 스크립트 (Ubuntu + nginx)
#   맥미니의 deploy.sh 가 index.html 과 함께 서버 /tmp/dsob/ 로 올린 뒤 실행합니다.
#   직접 실행:  sudo bash /tmp/dsob/setup.sh <로그인아이디>
#   - 기존 nginx 사이트(ygarchive 등)는 건드리지 않고 dsobgolf 사이트만 추가합니다.
#   - 비밀번호는 실행 중에 직접 입력합니다 (터미널 필요).
set -euo pipefail

DOMAIN="dsobgolf.duckdns.org"
SRC="$(cd "$(dirname "$0")" && pwd)"     # index.html 이 함께 올라온 폴더
WEB=/var/www/dsobgolf
DATA=/var/lib/dsobgolf
HTPASS=/etc/nginx/.htpasswd-dsobgolf
CONF=/etc/nginx/sites-available/dsobgolf
USER_ID="${1:-}"

[ "$(id -u)" = 0 ] || { echo "sudo 로 실행하세요: sudo bash $0 <아이디>"; exit 1; }

echo "== 1/6 패키지 설치"
apt-get update -qq
apt-get install -y -qq apache2-utils certbot python3-certbot-nginx >/dev/null

echo "== 2/6 페이지 파일 설치 ($WEB)"
[ -f "$SRC/index.html" ] || { echo "$SRC/index.html 이 없습니다. 맥미니에서 deploy.sh 로 실행하세요."; exit 1; }
mkdir -p "$WEB"
install -m 644 "$SRC/index.html" "$WEB/index.html"

echo "== 3/6 데이터 폴더 ($DATA)"
mkdir -p "$DATA"
chown www-data:www-data "$DATA"
chmod 750 "$DATA"

echo "== 4/6 로그인 계정"
if [ -f "$HTPASS" ]; then
  echo "   기존 계정 파일 유지: $HTPASS  (변경: sudo htpasswd $HTPASS <아이디>)"
else
  [ -n "$USER_ID" ] || { echo "아이디를 인자로 주세요: sudo bash $0 <아이디>"; exit 1; }
  [ -t 0 ] || { echo "비밀번호 입력을 위해 터미널에서 직접 실행하세요."; exit 1; }
  htpasswd -c -B "$HTPASS" "$USER_ID"
  chown root:www-data "$HTPASS"; chmod 640 "$HTPASS"
fi

echo "== 5/6 nginx 사이트 설정"
if [ ! -f "$CONF" ]; then
cat > "$CONF" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    root $WEB;
    index index.html;

    auth_basic "DSOB Golf";
    auth_basic_user_file $HTPASS;

    # 저장소 내부 파일 차단
    location ~ /\.(git|ht) { deny all; }
    location ^~ /deploy/ { deny all; }

    # 기록 데이터: GET 으로 읽고 PUT 으로 저장
    location = /data/data.json {
        alias $DATA/data.json;
        dav_methods PUT;
        create_full_put_path off;
        client_max_body_size 5m;
        add_header Cache-Control "no-store";
    }
}
EOF
fi
ln -sf "$CONF" /etc/nginx/sites-enabled/dsobgolf
nginx -t
systemctl reload nginx

echo "== 6/6 HTTPS 인증서 + 매일 백업"
if ! grep -q "listen 443" "$CONF"; then
  certbot --nginx -d "$DOMAIN" --redirect --non-interactive --agree-tos \
    || certbot --nginx -d "$DOMAIN" --redirect --non-interactive --agree-tos --register-unsafely-without-email
fi
cat > /etc/cron.daily/dsobgolf-backup <<'EOF'
#!/bin/sh
mkdir -p /var/backups/dsobgolf
[ -f /var/lib/dsobgolf/data.json ] && cp /var/lib/dsobgolf/data.json /var/backups/dsobgolf/data-$(date +%F).json
find /var/backups/dsobgolf -name 'data-*.json' -mtime +180 -delete
EOF
chmod 755 /etc/cron.daily/dsobgolf-backup

echo
echo "완료: https://$DOMAIN"
echo "확인 (401 이면 정상 = 비밀번호 보호 중): $(curl -s -o /dev/null -w '%{http_code}' https://$DOMAIN/ || true)"
