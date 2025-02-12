#!/bin/bash

# Atualiza pacotes do sistema
sudo apt update && sudo apt upgrade -y

# Instala dependências
sudo apt install -y curl wget nano unzip python3 python3-pip git

# Baixa e instala o Plex Media Server
wget https://downloads.plex.tv/plex-media-server-new/1.32.1.6999-43e6c633c/debian/plexmediaserver_1.32.1.6999-43e6c633c_amd64.deb
sudo dpkg -i plexmediaserver_1.32.1.6999-43e6c633c_amd64.deb

# Habilita e inicia o Plex Media Server
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# Cria diretório para armazenar vídeos
MEDIA_DIR="/mnt/videos"
sudo mkdir -p "$MEDIA_DIR"
sudo chown -R plex:plex "$MEDIA_DIR"

# Configura firewall para permitir acesso ao Plex
sudo ufw allow 32400/tcp

# Exibe IP e porta de acesso ao Plex
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Plex instalado com sucesso! Acesse: http://$IP_ADDRESS:32400/web"
