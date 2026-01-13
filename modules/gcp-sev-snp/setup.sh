#!/bin/bash
set -e

# Configure Docker daemon for better logging
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

# Ensure SEV device is mounted
sudo mount --bind /dev/sev-guest /dev/sev-guest

# Pull and run your container with mounted volumes
sudo docker pull ${container_image}
sudo docker run -d \
  --privileged \
  --name bearclave \
  -v /dev/sev-guest:/dev/sev-guest \
  ${container_image}
