#!/bin/bash
set -e

# Configure Docker daemon for better logging
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Restart Docker to apply configuration
sudo systemctl restart docker

# Ensure TDX device and kernel config are mounted
sudo mount --bind /dev/tdx-guest /dev/tdx-guest
sudo mount --bind /sys/kernel/config /sys/kernel/config

# Pull and run your container with mounted volumes
sudo docker pull ${container_image}
sudo docker run -d \
  --privileged \
  --name bearclave \
  -v /dev/tdx-guest:/dev/tdx-guest \
  -v /sys/kernel/config:/sys/kernel/config \
  ${container_image}
