#!/bin/bash
set -e

echo "=== Starting TDX setup script ==="

echo "Mounting TDX devices..."
sudo mount --bind /dev/tdx-guest /dev/tdx-guest 2>/dev/null || true
sudo mount --bind /sys/kernel/config /sys/kernel/config 2>/dev/null || true

echo "=== TDX setup script complete ==="
