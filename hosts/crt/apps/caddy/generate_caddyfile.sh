#!/bin/bash

# --- CONFIGURATION ---
MY_DOMAIN="adishy.com"
CADDY_DIR="/mnt/das_fast/personal.data.adishy.com/tmp/apps/caddy"
mkdir -p "$CADDY_DIR"

# 1. Write the Caddyfile
# We use http:// here to avoid SSL errors since we aren't using the DNS challenge
cat <<EOF > "$CADDY_DIR/Caddyfile"
# --- JELLYFIN ---
# URL: http://jellyfin.crt.$MY_DOMAIN
http://jellyfin.$MY_DOMAIN {
    reverse_proxy jellyfin:8096
}

# Local LAN Access
:8096 {
    reverse_proxy jellyfin:8096
}
EOF

# 2. Reload Caddy
if [ "$(docker ps -q -f name=caddy)" ]; then
    docker exec -w /etc/caddy caddy caddy reload
    echo "Caddy updated. Ensure jellyfin.crt.$MY_DOMAIN points to 100.89.59.97 in your DNS."
fi
