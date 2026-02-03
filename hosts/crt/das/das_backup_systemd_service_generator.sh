#!/bin/bash

# Configuration
REAL_SCRIPT="/home/adishy/personal.data.adishy.com/config/hosts/crt/das/backup_das.sh"
RCLONE_CONF="/home/adishy/personal.data.adishy.com/config/hosts/crt/das/rclone.conf"

# List your drives here: "LocalPath:RemoteName:"
DRIVES=(
    "/mnt/das_fast:das_fast_backup_bucket:"
    "/mnt/das_storage:das_storage_backup_bucket:"
)

for ENTRY in "${DRIVES[@]}"; do
    SRC="${ENTRY%%:*}"
    DEST="${ENTRY#*:}"
    
    # Generate a unique name for systemd
    SAFE_NAME=$(echo "${SRC#/}" | tr '/' '-')
    UNIT_NAME="b2-sync-${SAFE_NAME}"

    echo "Generating units for $UNIT_NAME..."

    # Create Service File
    sudo tee /etc/systemd/system/${UNIT_NAME}.service > /dev/null <<EOF
[Unit]
Description=B2 Sync for $SRC
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$REAL_SCRIPT $SRC $DEST
# Hard kill after 6 hours as a fail-safe
RuntimeMaxSec=21600
# Run cleanup even if the service is killed
ExecStopPost=/usr/bin/rclone cleanup $DEST --config $RCLONE_CONF
EOF

    # Create Timer File (Starts at 1:00 AM)
    sudo tee /etc/systemd/system/${UNIT_NAME}.timer > /dev/null <<EOF
[Unit]
Description=Run B2 Sync for $SRC nightly at 1AM

[Timer]
OnCalendar=*-*-* 01:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Activate
    sudo systemctl daemon-reload
    sudo systemctl enable --now ${UNIT_NAME}.timer
done

echo "Setup complete. Use 'systemctl list-timers' to check status."
