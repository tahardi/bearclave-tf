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

# Ensure SEV device is mounted
sudo mount --bind /dev/sev-guest /dev/sev-guest

# Pull and run container image. Make sure to mount SEV device and network ports
sudo docker pull ${container_image}
sudo docker run -d \
  --privileged \
  --name bearclave \
  -v /dev/sev-guest:/dev/sev-guest \
  -p 80:80 \
  -p 8080:8080 \
  -p 443:443 \
  -p 8443:8443 \
  ${container_image}
