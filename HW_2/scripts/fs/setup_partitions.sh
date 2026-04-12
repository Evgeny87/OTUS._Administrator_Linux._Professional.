#!/usr/bin/env bash
set -euo pipefail

log() { logger -t RAID_DEPLOY "[FS_PART] $1"; echo "$1"; }

FORCE=false
[[ "${1:-}" == "--force" ]] && { FORCE=true; shift; }
DEV=$1; COUNT=$2

if [[ "$FORCE" == "false" ]] && [[ $(lsblk -nlo NAME "$DEV" | wc -l) -gt 1 ]]; then
    log "[SKIP] $DEV already partitioned."
    exit 0
fi

log "Partitioning $DEV into $COUNT parts"
parted -s "$DEV" mklabel gpt
for i in $(seq 1 "$COUNT"); do
    START=$(( (i-1) * 100 / COUNT )); END=$(( i * 100 / COUNT ))
    [[ $i -eq $COUNT ]] && END=100
    parted -s "$DEV" mkpart primary ext4 "${START}%" "${END}%"
done
