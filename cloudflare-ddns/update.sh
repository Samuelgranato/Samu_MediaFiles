#!/bin/bash
set -e

source "__BASE_DIR__/.env"

IP=$(curl -s https://api.ipify.org)

ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CUSTOM_DOMAIN" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$CUSTOM_DOMAIN" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" | jq -r '.result[0].id')

curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$CUSTOM_DOMAIN\",\"content\":\"$IP\",\"ttl\":120,\"proxied\":false}" > /dev/null
