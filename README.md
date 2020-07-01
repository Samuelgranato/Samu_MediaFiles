# 🚀 Self-Hosted Media Server

This project provides an automated setup for a self-hosted media server using **Jellyfin**, **Syncthing**, **NGINX (reverse proxy with SSL)**, and **DuckDNS** for dynamic DNS. The setup is containerized using **Docker Compose**.

---

## What You Can Do With This Setup

### ✅ **Secure Media Streaming (HTTPS)**

- **Jellyfin** is used as the media server, allowing you to stream your movies, TV shows, and music from anywhere.
- With **NGINX** as a reverse proxy and **Let's Encrypt SSL**, your media is served securely via HTTPS.

### 🌎 **Access Your Server from Anywhere (Dynamic DNS)**

- **DuckDNS** ensures that even if your public IP changes, your server remains accessible with a custom domain.
- This is perfect for home-hosted servers where IP addresses can change frequently.

### 🔄 **Automatic Media Synchronization**

- **Syncthing** allows you to automatically sync your media files across multiple devices, including:
  - Other servers
  - Personal computers
  - Mobile devices 📱
- This ensures that your media collection is always up-to-date, regardless of where you store or edit files.

### 💰 **Completely Free & Open Source**

- Unlike paid streaming solutions, this setup is **100% free** with no monthly costs.
- Jellyfin is an **open-source alternative to Plex**, offering full customization and no forced subscriptions.

### 🚀 **Optimized for Performance**

- Uses **Docker Compose** for simple deployment and management.
- Secure configuration with **automatic SSL renewal** and **port forwarding** recommendations.

---

This setup is ideal for those who want **full control** over their media streaming, backups, and remote access **without relying on third-party services**. 💪

---

## 🛠️ Installation Guide

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Samuelgranato/Samu_MediaFiles.git
cd Samu_MediaFiles
```

### 2️⃣ Configure Environment Variables

Rename the provided `default_config.env` file to `config.env`:

```bash
cp default_config.env config.env
```

Edit `config.env` to match your desired configuration:

```bash
nano config.env
```

> Ensure you provide your **DuckDNS API key** and **custom domain (if applicable)**.

### 3️⃣ Run the Installation Script

Execute the setup script:

```bash
bash setup-server.sh
```

This script will:

- Install necessary dependencies (Docker, Certbot, etc.).
- Configure DuckDNS.
- Set up the **NGINX reverse proxy** with SSL.
- Deploy the **Docker Compose stack**.

### 4️⃣ Access Your Services

- **Jellyfin**: `https://your-custom-domain:YOUR_EXTERNAL_PORT`
- **Syncthing**: `http://localhost:8384`

---

## ⚙️ Configuration Overview

### **Environment Variables (config.env)**

| Variable                 | Description                                              |
| ------------------------ | -------------------------------------------------------- |
| `DUCKDNS_API_KEY`        | Your **DuckDNS API Key** (mandatory)                     |
| `DUCKDNS_SUBDOMAIN`      | Your **DuckDNS subdomain**                               |
| `CUSTOM_DOMAIN`          | Your **custom domain (e.g., example.com)**               |
| `SSL_EMAIL`              | Your email for Let's Encrypt                             |
| `JELLYFIN_PORT_INTERNAL` | Jellyfin's internal port (default: 8096)                 |
| `JELLYFIN_PORT_SECURE`   | Jellyfin's secure port (default: 8920)                   |
| `JELLYFIN_PORT_EXTERNAL` | **Port to expose externally (must be opened in router)** |
| `NGINX_HTTP_PORT`        | Nginx HTTP port (default: 80)                            |
| `NGINX_HTTPS_PORT`       | Nginx HTTPS port (default: 443)                          |
| `NGINX_CUSTOM_PORT`      | Custom port for external access (default: 44889)         |
| `DOCKER_NETWORK`         | Docker network name (default: media_network)             |
| `SYSTEM_USER`            | Your system user (used for service permissions)          |

## 🔄 Updating

To update services, run:

```bash
docker compose pull
docker compose up -d
```

To update the **SSL certificate**, run:

```bash
docker exec certbot certbot renew --force-renewal
```

---

## ❓ Troubleshooting

### NGINX Fails to Start Due to SSL Certificate Error

If NGINX fails with an error related to missing certificates, ensure they exist at:

```bash
ls -l $HOME/server/nginx/letsencrypt/live/your-domain.com/
```

If missing, regenerate them manually:

```bash
docker run --rm -it \
  -v "$HOME/server/nginx/letsencrypt:/etc/letsencrypt" \
  certbot/certbot certonly --manual --preferred-challenges dns \
  -d "your-domain.com" --agree-tos --no-eff-email --email "your-email@example.com"
```

### Ports Are Not Open

Check if your firewall allows external access:

```bash
sudo ufw status
```

Ensure your **router's port forwarding** maps the correct external ports to internal ones.

### DuckDNS Is Not Updating

Verify the systemd service status:

```bash
sudo systemctl status duckdns
```

Run the script manually:

```bash
bash ~/duckdns/update.sh
```

---

## 📜 License

This project is licensed under the **MIT License**.

---

## 🙌 Credits

- [Jellyfin](https://jellyfin.org/)
- [Syncthing](https://syncthing.net/)
- [NGINX](https://nginx.org/)
- [DuckDNS](https://www.duckdns.org/)
- [Let's Encrypt](https://letsencrypt.org/)

---

## 🌟 Support & Contributions

- **Found a bug?** Open an [issue](https://https://github.com/Samuelgranato/Samu_MediaFiles/issues)
- **Want to contribute?** Fork the repo and submit a pull request!

🚀 Happy self-hosting!
