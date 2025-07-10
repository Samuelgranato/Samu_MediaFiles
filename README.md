
# 🚀 Self-Hosted Media Server com Cloudflare DDNS

Este projeto oferece um setup automatizado para um servidor de mídia local utilizando **Jellyfin**, **Syncthing**, **NGINX (com proxy reverso e SSL)** e **Cloudflare** para DNS dinâmico e emissão automática de certificados com Certbot.

---

## ✅ Funcionalidades

- 🎞️ **Streaming seguro de mídia com HTTPS via Jellyfin**
- 🌐 **Atualização automática de IP usando Cloudflare DDNS**
- 🔐 **Certificados SSL automáticos com Certbot + plugin Cloudflare**
- ♻️ **Sincronização de arquivos entre dispositivos via Syncthing**
- 🐳 **Ambiente isolado com Docker Compose**
- 🧠 **Script de instalação inteligente que automatiza tudo**

---

## 🧾 Requisitos

- Ubuntu 22.04 ou superior
- Conta na [Cloudflare](https://dash.cloudflare.com/)
- Token de API da Cloudflare com permissões para:
  - Editar zona DNS (Zone.DNS)
  - Ler zona (Zone.Zone)

---

## 🔧 Instalação

### 1️⃣ Clone o repositório

```bash
git clone https://github.com/Samuelgranato/Samu_MediaFiles.git
cd Samu_MediaFiles
```

### 2️⃣ Configure o arquivo `.env`

Copie o exemplo:

```bash
cp default_config.env config.env
```

Edite `config.env` com suas configurações:

```dotenv
CLOUDFLARE_API_TOKEN=seu_token
CLOUDFLARE_ZONE_ID=sua_zone_id
CUSTOM_DOMAIN=seudominio.com
SSL_EMAIL=seu@email.com

JELLYFIN_PORT_INTERNAL=8096
JELLYFIN_PORT_EXTERNAL=44889
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

BASE_DIR=$HOME/server
SYSTEM_USER=seu_usuario_linux
```

### 3️⃣ Execute o script de instalação

```bash
chmod +x setup-server.sh
./setup-server.sh
```

---

## 🖥️ Serviços

- Jellyfin: `https://seudominio.com:44889`
- Syncthing: `http://localhost:8384`
- Certbot + NGINX: HTTPS com proxy reverso
- Cloudflare DDNS via serviço systemd

---

## 🔄 Atualizações

Atualizar serviços Docker:

```bash
docker compose pull
docker compose up -d
```

Renovar certificado manualmente (geralmente automático):

```bash
docker exec certbot certbot renew --force-renewal
```

---

## 🧪 Solução de Problemas

### Erro no NGINX: "invalid number of arguments"

Verifique se seu `nginx.conf.template` contém variáveis válidas como:

```nginx
proxy_set_header Host $host;
```

Evite usar `\$host` dentro do template.

### Certificado SSL ausente

Certifique-se de que os certificados estão montados corretamente:

```bash
ls $BASE_DIR/nginx/letsencrypt/live/seudominio.com/
```

---

## 📂 Estrutura do Projeto

```
server/
├── certbot/
├── cloudflare-ddns/
├── media/
├── jellyfin-config/
├── syncthing-config/
├── syncthing-data/
├── nginx/
│   ├── nginx.conf.template
│   ├── letsencrypt/
│   └── www/
└── docker-compose.yml
```

---

## 📜 Licença

MIT © Samuel Granato

---

## 🙌 Créditos

- [Jellyfin](https://jellyfin.org/)
- [Syncthing](https://syncthing.net/)
- [NGINX](https://nginx.org/)
- [Cloudflare](https://cloudflare.com/)
- [Certbot](https://certbot.eff.org/)
