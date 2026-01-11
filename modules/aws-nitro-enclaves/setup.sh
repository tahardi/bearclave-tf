#!/bin/bash
set -e

# Install dependencies
sudo dnf update -y
sudo dnf install -y \
  docker \
  aws-nitro-enclaves-cli-1.4.0 \
  aws-nitro-enclaves-cli-devel-1.4.0 \
  git \
  vim \
  make

# Configure docker and nitro-cli
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo usermod -aG ne ec2-user
sudo systemctl enable --now nitro-enclaves-allocator.service
sudo systemctl enable --now docker

# Configure git and vim
sudo -u ec2-user bash << 'GITEOF'
cat > ~/.gitconfig << 'EOF'
[core]
    editor = vim
[init]
    defaultBranch = main
[push]
    autoSetupRemote = true
[fetch]
    prune = true
EOF

echo 'export EDITOR=vim' >> ~/.bashrc
echo 'export VISUAL=vim' >> ~/.bashrc
GITEOF

# Install Go and clone bearclave-examples
sudo -u ec2-user bash << 'GOEOF'
cd ~

# Clone first and extract Go version that Bearclave uses
git clone https://github.com/tahardi/bearclave-examples.git
cd bearclave-examples
GO_VERSION=$(grep -oP '(?<=^go ).*' go.mod)

# Install and configure Go
cd ~
curl -O https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

cat >> ~/.bashrc << 'EOF'
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
EOF
GOEOF
