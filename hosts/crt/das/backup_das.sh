#!/bin/bash

# Configuration
SCRIPT_DIR="/home/adishy/personal.data.adishy.com/config/hosts/crt/das"
MY_CONFIG="$SCRIPT_DIR/rclone.conf"

SRC=$1
DEST=$2

# 1. Validation
if [[ -z "$SRC" || -z "$DEST" ]]; then
    echo "Error: Missing arguments. Usage: $0 <source> <remote:>"
    exit 1
fi

# 2. Mount Check (Crucial for Btrfs/Ext4 drives)
if ! mountpoint -q "$SRC"; then
    echo "$(date): ERROR - $SRC is not mounted. Aborting sync." >&2
    exit 1
fi

# 3. Calculate Time Remaining until 06:30 AM
CURRENT_TIME=$(date +%s)
DEADLINE=$(date -d "06:30" +%s)
if [ "$CURRENT_TIME" -gt "$DEADLINE" ]; then
    DEADLINE=$(date -d "tomorrow 06:30" +%s)
fi
SECONDS_LEFT=$(( DEADLINE - CURRENT_TIME ))

# 4. Define Flags (Optimized for B2 Chunking)
RCLONE_FLAGS="--config $MY_CONFIG \
--delete-during \
--fast-list \
--transfers 4 \
--checkers 8 \
--verbose \
--ignore-errors \
--b2-chunk-size 96M \
--b2-upload-cutoff 128M \
--max-duration ${SECONDS_LEFT}s"

echo "STARTING: rclone sync $SRC -> $DEST (Deadline: 06:30 AM)"

# 5. Execute Sync
rclone sync "$SRC" "$DEST" $RCLONE_FLAGS

# 6. Cleanup partials
# This ensures you don't pay for unfinished fragments if the timer cuts it off
rclone cleanup "$DEST" --config "$MY_CONFIG"
