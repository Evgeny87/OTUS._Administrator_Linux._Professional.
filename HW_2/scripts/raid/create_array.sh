#!/usr/bin/env bash
set -euo pipefail
log() { logger -t RAID_DEPLOY "[CREATE] $1"; echo "$1"; }
RAID_DEV=$1; LEVEL=$2; COUNT=$3; shift 3; DISKS=$@

# Проверка, не активен ли уже рейд
if grep -q "$(basename "$RAID_DEV")" /proc/mdstat; then 
    log "[SKIP] $RAID_DEV is already active."
    exit 0 
fi

log "Cleaning metadata on $DISKS..."
for disk in $DISKS; do
    wipefs -a "$disk"
    mdadm --zero-superblock --force "$disk"
done

log "Creating RAID $RAID_DEV..."
# Используем безопасную инициализацию с бэкапом метаданных
mdadm --create --run --verbose "$RAID_DEV" --level="$LEVEL" --raid-devices="$COUNT"  $DISKS

log "Updating mdadm.conf..."
mkdir -p /etc/mdadm
# Формируем строку конфига
CONF_LINE=$(mdadm --detail --scan --verbose | grep "ARRAY $RAID_DEV" || true)

# Добавляем строку только если её там еще нет (Идемпотентность)
if [[ -n "$CONF_LINE" ]]; then
    grep -qxF "$CONF_LINE" /etc/mdadm/mdadm.conf || echo "$CONF_LINE" >> /etc/mdadm/mdadm.conf
fi

log "Updating initramfs..."
if command -v update-initramfs &>/dev/null; then update-initramfs -u; fi
