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

# Enable IPv6 on the host
#sudo sysctl -w net.ipv6.conf.all.forwarding=1
#sudo sysctl -w net.ipv6.conf.all.accept_ra=2
#sudo sysctl -w net.ipv6.conf.default.forwarding=1

# Enable IPv4/IPv6 dual-stack
#sudo sysctl -w net.ipv4.ip_forward=1
#sudo sysctl -w net.ipv4.conf.all.rp_filter=0

# Pull and run container image. Make sure to mount SEV device and expose the
# host network to the container.
#sudo docker pull ${container_image}
#sudo docker run -d \
#  --privileged \
#  --name bearclave \
#  --net host \
#  -v /dev/sev-guest:/dev/sev-guest \
#  ${container_image}
