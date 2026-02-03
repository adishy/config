disk_pool=$1

journalctl -u b2-sync-mnt-das-$disk_pool -f
