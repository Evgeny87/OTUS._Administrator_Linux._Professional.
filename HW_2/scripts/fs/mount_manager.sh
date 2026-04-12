#!/usr/bin/env bash
set -euo pipefail

log() { logger -t RAID_DEPLOY "[MOUNT] $1"; echo "$1"; }

PART=$1; MNT=$2
if mountpoint -q "$MNT"; then exit 0; fi

log "Formatting $PART and mounting to $MNT"
mkfs.ext4 -F "$PART"
mkdir -p "$MNT"
mount "$PART" "$MNT"

[[ ! -f /etc/fstab.orig ]] && cp /etc/fstab /etc/fstab.orig
UUID=$(blkid -s UUID -o value "$PART")
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID $MNT ext4 defaults 0 0" >> /etc/fstab
