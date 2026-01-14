#!/bin/bash
set -e

# Install Google Cloud Ops Agent
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure Ops Agent to collect Docker container logs
sudo tee /etc/google-cloud-ops-agent/config.yaml > /dev/null << 'EOF'
logging:
  receivers:
    docker_logs:
      type: files
      include_paths:
      - /var/lib/docker/containers/*/*.log
  service:
    pipelines:
      default_pipeline:
        receivers: [docker_logs]
EOF

sudo systemctl restart google-cloud-ops-agent

# Remove the gcplogs driver configuration since it's not working
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
