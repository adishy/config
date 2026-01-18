#!/bin/bash

# --- CONFIGURATION ---
MY_DOMAIN="adishy.com"
CADDY_DIR="/mnt/das_fast/personal.data.adishy.com/tmp/apps/caddy"
mkdir -p "$CADDY_DIR"

# 1. Write the Caddyfile
cat <<EOF > "$CADDY_DIR/Caddyfile"
{
    debug
}

# --- JELLYFIN ---
http://jellyfin.$MY_DOMAIN {
    reverse_proxy jellyfin:8096 {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
    }
}

# --- IMMICH ---
http://immich.$MY_DOMAIN {
    reverse_proxy immich_server:2283 {
        header_up Host {host}
        header_up X-Real-IP {remote_host}
        # Immich handles large photo/video uploads, so we increase the timeout
        transport http {
            read_timeout 360s
        }
    }
}

# Native Port Access for LAN
:8096 {
    reverse_proxy jellyfin:8096
}

:2283 {
    reverse_proxy immich_server:2283
}
EOF

# 2. Reload Caddy
if [ "$(docker ps -q -f name=caddy)" ]; then
    echo "Reloading Caddy..."
    docker exec -w /etc/caddy caddy caddy reload
    echo "Done!"
    echo "Caddyfile written:"
    cat "$CADDY_DIR/Caddyfile"
fi
