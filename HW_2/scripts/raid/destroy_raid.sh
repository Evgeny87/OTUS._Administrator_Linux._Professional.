#!/usr/bin/env bash
set -uo pipefail

log() { logger -t RAID_DEPLOY "[DESTROY] $1"; echo "$1"; }

usage() {
    echo "Usage: $(basename "$0") <raid_dev> <mount_root> [--force]"
    exit "${1:-0}"
}

[[ "${1:-}" == "-h" ]] && usage 0
[[ $# -lt 2 ]] && usage 1

RAID_DEV=$1; MNT_ROOT=$2; FORCE=${3:-""}

if [[ "$RAID_DEV" == "/dev/md0" || "$RAID_DEV" == "/dev/md1" ]] && [[ "$FORCE" != "--force" ]]; then
    log "[ERROR] Safety: will not destroy system RAID ($RAID_DEV) without --force"
    exit 1
fi

log "Starting destruction of $RAID_DEV"
umount -f ${RAID_DEV}p* 2>/dev/null || true

if [[ -f /etc/fstab ]]; then
    sed -i "\|$MNT_ROOT|d" /etc/fstab
    log "fstab cleaned."
fi

if mdadm --detail "$RAID_DEV" &>/dev/null; then
    DISKS=$(mdadm --detail "$RAID_DEV" | grep -oE "/dev/(sd[a-z]|vd[a-z]|nvme[0-9]n[0-9])" | sort -u)
    mdadm --stop "$RAID_DEV"
    log "RAID stopped."
    for disk in $DISKS; do
        mdadm --zero-superblock --force "$disk" 2>/dev/null || true
        wipefs -a "$disk" 2>/dev/null || true
    done
fi

sed -i "\|ARRAY $RAID_DEV|d" /etc/mdadm/mdadm.conf 2>/dev/null || true
log "Cleanup finished."
