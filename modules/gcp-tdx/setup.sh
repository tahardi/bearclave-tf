#!/bin/bash
set -e

# Log all output for debugging
exec 1> >(logger -s -t $(basename $0))
exec 2>&1

echo "=== Starting TDX setup script ==="

# Download Ops Agent installer
echo "Downloading Ops Agent installer..."
if ! curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh; then
  echo "ERROR: Failed to download Ops Agent installer"
  # Don't exit - continue with other setup
fi

# Install Ops Agent
if [ -f add-google-cloud-ops-agent-repo.sh ]; then
  echo "Running Ops Agent installer..."
  if ! sudo bash add-google-cloud-ops-agent-repo.sh --also-install; then
    echo "WARNING: Ops Agent installation failed (this is okay if not available on this image)"
  fi
else
  echo "WARNING: Ops Agent installer script not found"
fi

# Configure Ops Agent if it exists
if sudo systemctl list-unit-files 2>/dev/null | grep -q google-cloud-ops-agent; then
  echo "Configuring Ops Agent..."
  sudo mkdir -p /etc/google-cloud-ops-agent
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
  sudo systemctl restart google-cloud-ops-agent || echo "WARNING: Failed to restart Ops Agent"
else
  echo "WARNING: google-cloud-ops-agent service not found, skipping Ops Agent config"
fi

# Configure Docker
echo "Configuring Docker..."
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

sudo systemctl restart docker
echo "Docker configured"

# Ensure TDX device and kernel config are mounted
echo "Mounting TDX devices..."
sudo mount --bind /dev/tdx-guest /dev/tdx-guest 2>/dev/null || true
sudo mount --bind /sys/kernel/config /sys/kernel/config 2>/dev/null || true

echo "=== TDX setup script complete ==="
