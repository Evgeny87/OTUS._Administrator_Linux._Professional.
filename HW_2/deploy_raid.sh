#!/usr/bin/env bash
set -euo pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE}")" && pwd)
ROOT_DISK=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /) | head -n 1)
DISKS=$(lsblk -dnpo NAME,MOUNTPOINT | grep -v "$ROOT_DISK" | grep -v "loop" | awk '$2=="" {print $1}' | head -n 4)

logger -t RAID_DEPLOY -- "--- Start Deployment ---"

"$BASE_DIR/scripts/raid/create_array.sh" /dev/md10 10 4 $DISKS
"$BASE_DIR/scripts/fs/setup_partitions.sh" --force /dev/md10 5

for i in {1..5}; do
    "$BASE_DIR/scripts/fs/mount_manager.sh" "/dev/md10p$i" "/mnt/raid10/part$i"
done

logger -t RAID_DEPLOY -- "--- Deployment Success ---"
