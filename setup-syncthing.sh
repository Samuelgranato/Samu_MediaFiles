#!/bin/bash

echo "🔹 Atualizando pacotes e instalando Syncthing..."
sudo apt update && sudo apt install -y syncthing ufw

echo "🔹 Criando serviço systemd para Syncthing..."
sudo tee /etc/systemd/system/syncthing.service > /dev/null <<EOT
[Unit]
Description=Syncthing File Sync Service
After=network.target

[Service]
ExecStart=/usr/bin/syncthing -no-browser -logflags=0
Restart=always
User=ubuntu
Group=ubuntu
Environment=HOME=/home/ubuntu
WorkingDirectory=/home/ubuntu

[Install]
WantedBy=multi-user.target
EOT

echo "🔹 Habilitando e iniciando Syncthing..."
sudo systemctl daemon-reload
sudo systemctl enable syncthing
sudo systemctl start syncthing

echo "🔹 Ajustando permissões da pasta de vídeos..."
sudo mkdir -p /mnt/plex-videos
sudo chown -R ubuntu:ubuntu /mnt/plex-videos
sudo chmod -R 775 /mnt/plex-videos

echo "🔹 Ajustando permissões para Plex (opcional)..."
sudo chown -R plex:plex /mnt/plex-videos
sudo chmod -R 777 /mnt/plex-videos

echo "🔹 Verificando se o volume está montado como somente leitura..."
MOUNT_STATUS=$(mount | grep /mnt/plex-videos | grep -o 'ro')

if [ "$MOUNT_STATUS" == "ro" ]; then
    echo "⚠️ O volume está somente leitura! Remontando como leitura/escrita..."
    sudo mount -o remount,rw /mnt/plex-videos
else
    echo "✅ O volume já está configurado para leitura/escrita."
fi

echo "🔹 Liberando portas no firewall (UFW)..."
sudo ufw allow 22000/tcp  # Transferência de Arquivos
sudo ufw allow 21027/udp  # Descoberta de Rede
sudo ufw reload

echo "✅ Configuração concluída! Você pode acessar o Syncthing em:"
echo "   ➤ http://SEU_IP_PUBLICO:8384"
