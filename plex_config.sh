#!/bin/bash

# Atualiza pacotes do sistema
sudo apt update && sudo apt upgrade -y

# Instala dependências
sudo apt install -y curl wget nano unzip python3 python3-pip git ufw

echo "y" |  sudo ufw enable

# Baixa e instala o Plex Media Server
wget https://downloads.plex.tv/plex-media-server-new/1.41.3.9314-a0bfb8370/debian/plexmediaserver_1.41.3.9314-a0bfb8370_amd64.deb
sudo dpkg -i plexmediaserver_1.41.3.9314-a0bfb8370_amd64.deb

# Habilita e inicia o Plex Media Server
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

# Cria diretório para armazenar vídeos
MEDIA_DIR="/mnt/videos"
sudo mkdir -p "$MEDIA_DIR"
sudo chown -R plex:plex "$MEDIA_DIR"

# Configura firewall para permitir acesso ao Plex
sudo ufw allow 32400/tcp
sudo ufw allow 22/tcp
sudo ufw allow 22000/tcp
sudo ufw allow 21027/udp
echo "y" | sudo ufw reload

# Exibe IP e porta de acesso ao Plex
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Plex instalado com sucesso! Reiniciando. Após, acesse: http://$IP_ADDRESS:32400/web"

sudo reboot
