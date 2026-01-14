#!/bin/bash
set -e

echo "=== Starting SEV-SNP setup script ==="

echo "Configuring GCP Logger..."
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

echo "Mounting SEV-SNP device..."
sudo mount --bind /dev/sev-guest /dev/sev-guest

echo "=== SEV-SNP setup script complete ==="
