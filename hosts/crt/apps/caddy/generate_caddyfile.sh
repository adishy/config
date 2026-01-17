#!/bin/bash

# Define the target path
CADDY_DIR="/mnt/das_fast/personal.data.adishy.com/tmp/apps/caddy"
mkdir -p "$CADDY_DIR"

# 1. Ensure the shared network exists
docker network inspect crt_service_intranet >/dev/null 2>&1 || \
docker network create crt_service_intranet

# 2. Get the Tailnet name
TAILNET_NAME=$(tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

if [ -z "$TAILNET_NAME" ]; then
    echo "Error: Could not determine Tailnet name. Is Tailscale running?"
    exit 1
fi

# 3. Write the Caddyfile
# Note: Local access uses the native ports (:8096) directly via Caddy
cat <<EOF > "$CADDY_DIR/Caddyfile"
# --- JELLYFIN ---
# Tailnet Access (HTTPS)
jellyfin.$TAILNET_NAME {
    tls {
        get_certificate tailscale
    }
    reverse_proxy jellyfin:8096
}

# Local LAN Access (Native Port)
:8096 {
    reverse_proxy jellyfin:8096
}

# --- FUTURE APPS (Example: Immich) ---
# immich.$TAILNET_NAME {
#     tls {
#         get_certificate tailscale
#     }
#     reverse_proxy immich-server:2283
# }
# :2283 {
#     reverse_proxy immich-server:2283
# }
EOF

echo "Caddyfile generated at $CADDY_DIR/Caddyfile"

# 4. Reload Caddy automatically
if [ "$(docker ps -q -f name=caddy)" ]; then
    echo "Reloading Caddy..."
    docker exec -w /etc/caddy caddy caddy reload
else
    echo "Caddy container is not running. Start it with 'docker compose up -d --build'."
fi
