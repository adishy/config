#!/bin/bash

# --- CONFIGURATION ---
FAST_POOL_DEVS=("sda" "sdb" "sdc")
STORAGE_POOL_DEVS=("sdd" "sde" "sdf" "sdg")
MOUNT_FAST="/mnt/das_fast"
MOUNT_STORAGE="/mnt/das_storage"

echo "=========================================================="
echo "   TERRAMASTER D8 HYBRID - POP!_OS SETUP HELPER"
echo "=========================================================="

# 1. HARDWARE DETECTION
echo -e "\n[1] HARDWARE DETECTION (lshw):"
sudo lshw -short -C disk | grep -E "$(echo ${FAST_POOL_DEVS[@]} ${STORAGE_POOL_DEVS[@]} | sed 's/ /|/g')"

# 2. RESOLVE IDs
declare -A ID_MAP
for dev in "${FAST_POOL_DEVS[@]}" "${STORAGE_POOL_DEVS[@]}"; do
    ID=$(ls -l /dev/disk/by-id/ | grep -v "part" | grep "../../$dev" | awk '{print $9}' | head -n 1)
    ID_MAP[$dev]="/dev/disk/by-id/$ID"
done

# 3. WIPE COMMANDS
echo -e "\n[2] COMMANDS TO WIPE DRIVES:"
echo "----------------------------------------------------------"
echo "sudo vgchange -an pve  # Deactivate old LVM if present"
for dev in "${!ID_MAP[@]}"; do
    echo "sudo wipefs -af /dev/$dev"
    echo "sudo sgdisk --zap-all /dev/$dev"
done

# 4. BUILD COMMANDS
echo -e "\n[3] COMMANDS TO BUILD POOLS:"
echo "----------------------------------------------------------"
echo "# Build Fast Pool"
echo "sudo mkfs.btrfs -f -L fast -m raid1 -d raid1 \\"
for dev in "${FAST_POOL_DEVS[@]}"; do echo "  ${ID_MAP[$dev]} \\"; done
echo -e "\n# Build Storage Pool"
echo "sudo mkfs.btrfs -f -L storage -m raid1 -d raid1 \\"
for dev in "${STORAGE_POOL_DEVS[@]}"; do echo "  ${ID_MAP[$dev]} \\"; done

# 5. MOUNT & PERMISSIONS
echo -e "\n[4] COMMANDS TO MOUNT & SET PERMISSIONS:"
echo "----------------------------------------------------------"
echo "sudo mkdir -p $MOUNT_FAST $MOUNT_STORAGE"
echo "sudo mount /dev/disk/by-label/fast $MOUNT_FAST"
echo "sudo mount /dev/disk/by-label/storage $MOUNT_STORAGE"
echo "sudo chown -R \$USER:\$USER $MOUNT_FAST"
echo "sudo chown -R \$USER:\$USER $MOUNT_STORAGE"

# 6. FSTAB GENERATION (Correct 6-Column Format)
echo -e "\n[5] READY-TO-USE FSTAB LINES (RUN AFTER BUILDING):"
echo "----------------------------------------------------------"
# We use label matching to grab the exact UUIDs
FAST_UUID=$(lsblk -no UUID,LABEL | grep "fast$" | awk '{print $1}' | head -n 1)
STORAGE_UUID=$(lsblk -no UUID,LABEL | grep "storage$" | awk '{print $1}' | head -n 1)

if [ -n "$FAST_UUID" ]; then
    echo "UUID=$FAST_UUID  $MOUNT_FAST  btrfs  defaults,nofail,ssd,discard=async,compress=zstd,autodefrag  0  2"
else
    echo "# [!] Fast pool UUID not found. Build the pool first."
fi

if [ -n "$STORAGE_UUID" ]; then
    echo "UUID=$STORAGE_UUID  $MOUNT_STORAGE  btrfs  defaults,nofail,compress=zstd,autodefrag  0  2"
else
    echo "# [!] Storage pool UUID not found. Build the pool first."
fi
echo "----------------------------------------------------------"

# 7. ADDING DISKS MODE
echo -e "\n[6] ADDING DISKS LATER (FOR YOUR 2TB DRIVES):"
echo "----------------------------------------------------------"
echo "# Identify new drive ID, then:"
echo "sudo btrfs device add /dev/disk/by-id/NEW_ID_HERE $MOUNT_STORAGE"
echo "sudo btrfs balance start -dusage=0 $MOUNT_STORAGE"
