#!/usr/bin/env bash
set -uo pipefail

echo "=== INFRASTRUCTURE TESTS ==="
grep -q "active raid10" /proc/mdstat && echo "[PASS] RAID Active" || echo "[FAIL] RAID Inactive"
[[ $(lsblk -nlo NAME /dev/md10 | grep -E 'p[0-9]+$' | wc -l) -eq 5 ]] && echo "[PASS] 5 Partitions found" || echo "[FAIL] Partitions mismatch"
for i in {1..5}; do
    mountpoint -q "/mnt/raid10/part$i" && echo "[PASS] Part $i mounted" || echo "[FAIL] Part $i error"
done
