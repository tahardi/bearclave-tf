#!/bin/bash
set -e

echo "=== Starting TDX setup script ==="

# Configure Docker to use json-file driver with reasonable limits
echo "Configuring Docker..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "service=bearclave"
  }
}
EOF

sudo systemctl restart docker
echo "Docker restarted with json-file driver"

# Configure Fluent Bit to ship Docker logs to Cloud Logging
echo "Configuring Fluent Bit..."
sudo tee /etc/fluent-bit/config.d/docker.conf > /dev/null << 'EOF'
[INPUT]
    Name tail
    Path /var/lib/docker/containers/*/*.log
    Tag docker.*
    Parser docker
    DB /var/lib/fluent-bit/state-docker.db
    Mem_Buf_Limit 5MB
    Skip_Long_Lines On

[OUTPUT]
    Name stackdriver
    Match *
    resource k8s_container
    k8s_cluster_name bearclave-tdx
    k8s_cluster_location us-central1-a
EOF

# Restart Fluent Bit to pick up the new config
sudo systemctl restart fluent-bit || echo "Fluent Bit not available, skipping"

# Ensure TDX device and kernel config are mounted
echo "Mounting TDX devices..."
sudo mount --bind /dev/tdx-guest /dev/tdx-guest 2>/dev/null || true
sudo mount --bind /sys/kernel/config /sys/kernel/config 2>/dev/null || true

echo "=== TDX setup script complete ==="
