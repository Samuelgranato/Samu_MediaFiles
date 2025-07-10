#!/bin/bash

set -e

if [ ! -f "config.env" ]; then
    echo "Arquivo config.env não encontrado!"
    exit 1
fi

source config.env
cp config.env "$BASE_DIR/.env"

sudo apt update
sudo apt install -y curl git docker.io docker-compose certbot jq

if ! groups $USER | grep -q '\bdocker\b'; then
    sudo usermod -aG docker $USER
    echo "Reinicie a sessão para aplicar o grupo docker."
    DOCKER_SUDO="sudo"
else
    DOCKER_SUDO=""
fi

mkdir -p "$BASE_DIR"/{jellyfin-config,media,syncthing-config,syncthing-data,nginx/letsencrypt,nginx/www,cloudflare-ddns}
mkdir -p "$HOME/.secrets/certbot"

# Gera o cloudflare.ini com base na variável do config.env
echo "dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}" > "$HOME/.secrets/certbot/cloudflare.ini"
chmod 600 "$HOME/.secrets/certbot/cloudflare.ini"

cp cloudflare-ddns/update.sh "$BASE_DIR/cloudflare-ddns/update.sh"
cp cloudflare-ddns/cloudflare-ddns.service "$BASE_DIR/cloudflare-ddns/cloudflare-ddns.service"
cp cloudflare-ddns/cloudflare-ddns.timer "$BASE_DIR/cloudflare-ddns/cloudflare-ddns.timer"
chmod +x "$BASE_DIR/cloudflare-ddns/update.sh"

sed -i "s|ExecStart=.*|ExecStart=/bin/bash -c '$BASE_DIR/cloudflare-ddns/update.sh'|" "$BASE_DIR/cloudflare-ddns/cloudflare-ddns.service"
sed -i "s|source .*|source $BASE_DIR/.env|" "$BASE_DIR/cloudflare-ddns/update.sh"

sudo cp "$BASE_DIR/cloudflare-ddns/cloudflare-ddns.service" /etc/systemd/system/cloudflare-ddns.service
sudo cp "$BASE_DIR/cloudflare-ddns/cloudflare-ddns.timer" /etc/systemd/system/cloudflare-ddns.timer

mkdir -p "$BASE_DIR/nginx"
# Geração dinâmica do nginx.conf
echo "==> Gerando nginx.conf com variáveis do .env..."

# Exporta as variáveis do .env para o envsubst funcionar corretamente
set -a
source "$BASE_DIR/.env"
set +a

# Verifica se o template existe
if [ ! -f nginx/nginx.conf.template ]; then
    echo "❌ nginx.conf.template não encontrado em nginx/"
    exit 1
fi

# Gera o nginx.conf com as variáveis substituídas
envsubst '${CUSTOM_DOMAIN} ${JELLYFIN_PORT_EXTERNAL} ${JELLYFIN_PORT_INTERNAL}' \
  < nginx/nginx.conf.template > "$BASE_DIR/nginx/nginx.conf"

echo "✅ nginx.conf gerado com sucesso em $BASE_DIR/nginx/nginx.conf"

cp docker-compose.yml "$BASE_DIR/docker-compose.yml"

sudo systemctl daemon-reload
sudo systemctl enable cloudflare-ddns.service
sudo systemctl start cloudflare-ddns.service
sudo systemctl enable cloudflare-ddns.timer
sudo systemctl start cloudflare-ddns.timer

echo "Deseja gerar o certificado SSL agora? (y/n)"
read -r RESPOSTA

if [[ "$RESPOSTA" == "y" ]]; then
    $DOCKER_SUDO docker run --rm -it \
        -v "$BASE_DIR/nginx/letsencrypt:/etc/letsencrypt" \
        -v "$HOME/.secrets/certbot/cloudflare.ini:/root/.cloudflare.ini" \
        certbot-with-cloudflare certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials /root/.cloudflare.ini \
        -d "$CUSTOM_DOMAIN" \
        --agree-tos \
        --no-eff-email \
        --email "$SSL_EMAIL"
fi

cd "$BASE_DIR"
set -a
source .env
set +a

$DOCKER_SUDO docker compose down
$DOCKER_SUDO docker compose up -d

echo "Acesse Jellyfin: https://$CUSTOM_DOMAIN:$JELLYFIN_PORT_EXTERNAL"
echo "Acesse Syncthing: http://localhost:8384"
