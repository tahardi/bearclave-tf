#!/bin/bash
set -e

# Wait for Docker service to be available before doing anything
echo "Waiting for Docker daemon to start..."
for i in {1..60}; do
  if sudo systemctl is-active --quiet docker; then
    echo "Docker daemon is active"
    break
  fi
  echo "Waiting for Docker daemon... ($i/60)"
  sleep 1
done

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
