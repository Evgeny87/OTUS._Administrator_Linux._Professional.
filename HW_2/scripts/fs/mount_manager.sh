#!/usr/bin/env bash
set -euo pipefail

# Унифицированная функция логирования
log() { logger -t RAID_DEPLOY "[MOUNT] $1"; echo "$1"; }

usage() { echo "Usage: $(basename "$0") <partition> <mount_point>"; exit 1; }
[[ $# -ne 2 ]] && usage

PART=$1
MNT=$2

# 1. Идемпотентность: проверка текущего монтирования
if mountpoint -q "$MNT"; then
    log "[SKIP] $MNT is already a mountpoint."
    exit 0
fi

# 2. Безопасность: Бэкап fstab (делаем только один раз - исходный слепок)
if [[ ! -f /etc/fstab.orig ]]; then
    cp /etc/fstab /etc/fstab.orig
    log "Original fstab backup created at /etc/fstab.orig"
fi

# 3. Работа с ФС
log "Formatting $PART and mounting to $MNT"
mkfs.ext4 -F "$PART"
mkdir -p "$MNT"
mount "$PART" "$MNT"

# 4. Идемпотентность: запись в fstab по UUID без дублей
UUID=$(blkid -s UUID -o value "$PART")
if ! grep -q "$UUID" /etc/fstab; then
    echo "UUID=$UUID $MNT ext4 defaults 0 0" >> /etc/fstab
    log "Added UUID=$UUID to /etc/fstab"
else
    log "[SKIP] UUID=$UUID already present in fstab."
fi
