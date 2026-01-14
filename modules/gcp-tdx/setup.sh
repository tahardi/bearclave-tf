#!/bin/bash
set -e

# Configure Docker daemon to log to Google Cloud Logging
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "gcplogs",
  "log-opts": {
    "labels": "container=${container_image}"
  }
}
EOF

# Restart Docker to apply configuration
sudo systemctl restart docker

# Ensure TDX device and kernel config are mounted
sudo mount --bind /dev/tdx-guest /dev/tdx-guest
sudo mount --bind /sys/kernel/config /sys/kernel/config
