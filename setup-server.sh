#!/bin/bash

set -e  # Para o script parar em caso de erro

echo "==> Atualizando sistema e instalando dependências..."
sudo apt update
sudo apt install -y curl git docker.io docker-compose python3-distutils

# Adiciona usuário ao grupo Docker para não precisar de sudo (requer logout para aplicar)
sudo usermod -aG docker $USER

# Cria diretório do servidor e subdiretórios
BASE_DIR="$HOME/meu-servidor"
mkdir -p "$BASE_DIR"/{jellyfin-config,media,syncthing-config,syncthing-data}

# Cria docker-compose.yml dentro do diretório do servidor
cat <<EOF > "$BASE_DIR/docker-compose.yml"
version: '3.9'

services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"
      - "8920:8920"
    volumes:
      - ./jellyfin-config:/config
      - ./media:/media
    environment:
      - TZ=America/Sao_Paulo
    restart: unless-stopped
    networks:
      - media_network

  syncthing:
    image: syncthing/syncthing:latest
    container_name: syncthing
    ports:
      - "8384:8384"
      - "22000:22000/tcp"
      - "22000:22000/udp"
      - "21027:21027/udp"
    volumes:
      - ./syncthing-config:/var/syncthing/config
      - ./syncthing-data:/var/syncthing/data
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
    restart: unless-stopped
    networks:
      - media_network

networks:
  media_network:
    driver: bridge
EOF

# Move para a pasta do servidor
cd "$BASE_DIR"

# Sobe os containers
echo "==> Subindo Jellyfin e Syncthing..."
docker-compose up -d

echo "==> Instalação completa!"
echo "Acesse Jellyfin em: http://localhost:8096"
echo "Acesse Syncthing em: http://localhost:8384"

echo "==> IMPORTANTE: Faça logout ou reinicie para o grupo docker aplicar ao seu usuário."
