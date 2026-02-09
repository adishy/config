#!/bin/bash

# Configuration
REAL_SCRIPT="/home/adishy/personal.data.adishy.com/config/hosts/crt/das/backup_das.sh"
RCLONE_CONF="/home/adishy/personal.data.adishy.com/config/hosts/crt/das/rclone.conf"

# Updated DRIVES: "LocalPath:RemoteName:BucketName"
# This fixes the "can't purge from root" error by being explicit.
DRIVES=(
    "/mnt/das_fast:das_fast_backup_bucket:das-fast"
    "/mnt/das_storage:das_storage_backup_bucket:das-storage"
)

for ENTRY in "${DRIVES[@]}"; do
    SRC=$(echo "$ENTRY" | cut -d: -f1)
    REMOTE=$(echo "$ENTRY" | cut -d: -f2)
    BUCKET=$(echo "$ENTRY" | cut -d: -f3)
    DEST="${REMOTE}:${BUCKET}"

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
# Ensure the user running this has access to the home directory config
# Or run as your specific user instead of root:
# User=adishy
ExecStart=$REAL_SCRIPT $SRC $DEST
# Cleanup is specific to B2 and doesn't always apply to all remotes, 
# prefixing with '-' ignores errors so it doesn't mark the service as 'failed'
ExecStopPost=-/usr/bin/rclone cleanup $DEST --config $RCLONE_CONF
EOF

    # Create Timer File
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

echo "Setup complete. Run 'sudo chmod +x $REAL_SCRIPT' to fix potential EXEC errors."
