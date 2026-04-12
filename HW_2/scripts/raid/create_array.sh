#!/usr/bin/env bash
set -euo pipefail
log() { logger -t RAID_DEPLOY "[CREATE] $1"; echo "$1"; }
RAID_DEV=$1; LEVEL=$2; COUNT=$3; shift 3; DISKS=$@

if grep -q "$(basename "$RAID_DEV")" /proc/mdstat; then log "[SKIP] $RAID_DEV active."; exit 0; fi

log "Final cleaning of $DISKS..."
for disk in $DISKS; do
    wipefs -a "$disk"
    mdadm --zero-superblock --force "$disk" || true
done

log "Creating RAID $RAID_DEV..."
# Убрали --backup-file и добавили --run для автозапуска
mdadm --create --run --verbose "$RAID_DEV" --level="$LEVEL" --raid-devices="$COUNT" $DISKS

mkdir -p /etc/mdadm
mdadm --detail --scan --verbose | grep "ARRAY $RAID_DEV" >> /etc/mdadm/mdadm.conf || true

if command -v update-initramfs &>/dev/null; then update-initramfs -u; fi
