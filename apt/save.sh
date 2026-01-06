#!/bin/bash

# Define filenames
PKG_LIST="package_list.txt"
SRC_BACKUP="sources_backup.tar.gz"

echo "Step 1: Exporting manually installed packages..."
apt-mark showmanual > "$PKG_LIST"

echo "Step 2: Backing up repository sources..."
# We use tar to preserve the directory structure and file permissions
sudo tar -czf "$SRC_BACKUP" /etc/apt/sources.list /etc/apt/sources.list.d/

echo "---"
echo "Backup complete!"
echo "Files created: $PKG_LIST and $SRC_BACKUP"
echo "Make sure to move both files to your external storage/cloud."
