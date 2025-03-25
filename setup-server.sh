#!/bin/bash

set -e  # Stop execution if an error occurs

# Load configuration
if [ ! -f "config.env" ]; then
    echo "config.env file not found!"
    exit 1
fi
source config.env
cp config.env "$BASE_DIR/.env"

# echo "==> Updating system and installing Docker and dependencies..."
# sudo apt update
# sudo apt install -y curl git docker.io docker-compose certbot

# # Add user to the Docker group if necessary
# if ! groups $USER | grep -q '\bdocker\b'; then
#     echo "==> Adding $USER to the docker group..."
#     sudo usermod -aG docker $USER
#     echo "==> Log out or restart for the docker group to apply to your user."
#     DOCKER_SUDO="sudo"
# else
#     DOCKER_SUDO=""
# fi

# Create necessary directories
mkdir -p "$BASE_DIR"/{jellyfin-config,media,syncthing-config,syncthing-data,nginx/letsencrypt,nginx/www}
mkdir -p "$HOME/duckdns"

# Verify if the DuckDNS API key exists
if [ ! -f "$DUCKDNS_API_KEY_FILE" ]; then
    echo "DuckDNS API key file not found!"
    echo "Create the file $DUCKDNS_API_KEY_FILE with your API key before proceeding."
    exit 1
fi

# Copy configuration files
echo "==> Copying configuration files..."
cp duckdns/update.sh "$HOME/duckdns/update.sh"
cp duckdns/duckdns.service "$HOME/duckdns/duckdns.service"
chmod +x "$HOME/duckdns/update.sh"

# Modify only the `ExecStart` line dynamically inside the existing `duckdns.service`
echo "==> Configuring DuckDNS systemd service..."
sudo sed -i "s|source.*|source $HOME/server/config.env|" "$HOME/duckdns/update.sh"
sudo sed -i "s|curl.*|curl -k -o $HOME/duckdns/duckdns.log -K -|" "$HOME/duckdns/update.sh"
sudo sed -i "s|ExecStart=.*|ExecStart=/bin/bash -c '$HOME/duckdns/update.sh'|" $HOME/duckdns/duckdns.service

sudo cp "$HOME/duckdns/duckdns.service" /etc/systemd/system/duckdns.service
sudo cp duckdns/duckdns.timer /etc/systemd/system/duckdns.timer

sudo cp nginx/nginx.conf "$BASE_DIR/nginx/nginx.conf"
cp docker-compose.yml "$BASE_DIR/docker-compose.yml"

# Configure DuckDNS service
echo "==> Configuring DuckDNS service..."
sudo systemctl daemon-reload

sudo systemctl enable duckdns.service
sudo systemctl start duckdns.service

sudo systemctl enable duckdns.timer
sudo systemctl start duckdns.timer

# Ask user if they want to generate an SSL certificate now
echo "🔹 Do you want to generate the SSL certificate now? (y/n)"
read -r GENERATE_SSL

if [[ "$GENERATE_SSL" == "y" ]]; then
    echo "==> Generating SSL certificate for $CUSTOM_DOMAIN..."
    $DOCKER_SUDO docker run --rm -it \
    -v "$BASE_DIR/nginx/letsencrypt:/etc/letsencrypt" \
    certbot/certbot certonly --manual --preferred-challenges dns \
    -d "$CUSTOM_DOMAIN" --agree-tos --no-eff-email --email "$SSL_EMAIL"

    echo "SSL certificate successfully generated!"
else
    echo "Skipping SSL certificate generation."
fi

# Start services
cd "$BASE_DIR"
cp config.env "$BASE_DIR/.env"
set -a
source .env
set +a 

echo "==> Starting services with Docker Compose..."
$DOCKER_SUDO docker compose up -d

echo "==> Setup completed!"
echo "Access Jellyfin: https://$CUSTOM_DOMAIN:$JELLYFIN_PORT_EXTERNAL"
echo "Access Syncthing: http://localhost:8384"
