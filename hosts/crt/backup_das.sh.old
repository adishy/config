#!/bin/bash

# ==============================================================================
# USAGE EXAMPLES:
#
# 1. Scheduled Run (Automatically stops at 06:30 AM):
#    /usr/local/bin/rclone-job.sh /mnt/das_fast das_fast_backup_bucket:
#
# 2. Manual Run (Ignores the 06:30 AM deadline):
#    /usr/local/bin/rclone-job.sh -m /mnt/das_fast das_fast_backup_bucket:
#
# 3. Crontab Configuration (Run 'crontab -e' and add):
#    0 1 * * * /usr/local/bin/rclone-job.sh /mnt/das_fast das_fast_backup_bucket: >> /var/log/b2_fast.log 2>&1
#    0 1 * * * /usr/local/bin/rclone-job.sh /mnt/das_storage das_storage_backup_bucket: >> /var/log/b2_storage.log 2>&1
# ==============================================================================

MANUAL=false
SRC=""
DEST=""
MY_CONFIG="/home/adishy/personal.data.adishy.com/config/hosts/crt/rclone.conf"

# Parse flags
while getopts "m" opt; do
  case $opt in
    m) MANUAL=true ;;
    *) echo "Usage: $0 [-m] <source_path> <remote_name>"; exit 1 ;;
  esac
done

shift $((OPTIND -1))
SRC=$1
DEST=$2

# 1. Validation
if [[ -z "$SRC" || -z "$DEST" ]]; then
    echo "Error: Missing arguments."
    echo "Usage: $0 [-m] /path/to/source remote_name:"
    exit 1
fi

# 2. Mount Check
# Vital for Btrfs: ensures we don't sync an empty mount point and wipe the remote.
if ! mountpoint -q "$SRC"; then
    echo "$(date): ERROR - $SRC is not mounted. Aborting sync." >&2
    exit 1
fi

# 3. Define Rclone Flags
# --delete-during: Remote matches source (deletes on B2 if deleted on drive)
# --ignore-errors: Protects remote data if a local file is unreadable (IO error)


RCLONE_FLAGS="--config $MY_CONFIG --delete-during --fast-list --transfers 4 --checkers 8 --verbose --ignore-errors"

if [ "$MANUAL" = true ]; then
    echo "MODE: MANUAL - Running until completion."
else
    # Calculate time remaining until 06:30 AM
    CURRENT_TIME=$(date +%s)
    DEADLINE=$(date -d "06:30" +%s)
    
    # Target 06:30 AM tomorrow if it's already past the deadline today
    if [ "$CURRENT_TIME" -gt "$DEADLINE" ]; then
        DEADLINE=$(date -d "tomorrow 06:30" +%s)
    fi
    
    SECONDS_LEFT=$(( DEADLINE - CURRENT_TIME ))
    DURATION="${SECONDS_LEFT}s"
    
    echo "MODE: SCHEDULED - Target deadline 06:30 AM ($DURATION remaining)."
    RCLONE_FLAGS="$RCLONE_FLAGS --max-duration $DURATION"
fi

echo "STARTING: rclone sync $SRC -> $DEST"

# 4. Execute
rclone sync "$SRC" "$DEST" $RCLONE_FLAGS
