#!/bin/bash

# Define filenames
PKG_LIST="package_list.txt"
SRC_BACKUP="sources_backup.tar.gz"

# Check if files exist
if [[ ! -f "$PKG_LIST" ]]; then
    echo "Error: $PKG_LIST not found."
    exit 1
fi

if [[ ! -f "$SRC_BACKUP" ]]; then
    echo "Error: $SRC_BACKUP not found."
    exit 1
fi

echo "Step 1: Restoring repository sources..."
# Extract to root / so that etc/apt/... lands in /etc/apt/...
# (tar removes leading / by default during creation, so -C / puts it back in place)
sudo tar -xzf "$SRC_BACKUP" -C /

echo "Step 2: Updating package lists..."
sudo apt update

echo "Step 3: Re-installing manual packages..."
# Use xargs to pass the package list to apt install
# -r: do not run if input is empty
xargs -a "$PKG_LIST" -r sudo apt install -y

echo "---"
echo "Restore complete!"
