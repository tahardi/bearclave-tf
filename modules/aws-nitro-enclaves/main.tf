terraform {
  required_version = ">= 1.14.0, < 2.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Allow minor/patch updates (e.g., 6.29) but prevent major (e.g., v7)
      version = "~> 6.28"
    }
  }
}

locals {
  # AWS instance resources don't have an explicit name field. Instead, you add
  # a "Name" tag and the AWS console will use that as the display name.
  common_tags = merge({ Name = var.instance_name }, var.tags)
}

provider "aws" {
  region = var.aws_region
}

# Data source is read-only and will query AWS to check if a key-pair with this
# name exists in the provider-specified region. If it does not exist, the
# depends on in our aws_instance resource will throw an error during planning.
# This is to ensure our key exists in the region we want to deploy to.
data "aws_key_pair" "this" {
  key_name           = var.key_pair_name
  include_public_key = true
}

resource "aws_instance" "bcl_nitro" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bcl_nitro.id]
  tags                   = local.common_tags

  # Make sure the key pair actually exists
  depends_on = [data.aws_key_pair.this]

  # General purpose SSD w/16GB storage
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 16
    delete_on_termination = true
    encrypted             = true
  }

  enclave_options {
    enabled = true
  }

  # Enable the metadata service, but require tokens and only allow code running
  # on the instance to query the metadata service (hop limit = 1)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # This will run our setup script the first time our instance boots. Depending
  # on the complexity of the setup, you may want to use something like Ansible
  # Playbook instead. Since ours is simple and a one-off, this will do just fine.
  user_data = file("${path.module}/setup.sh")
}

# Create a security group that defines networking rules for the EC2 instance.
# Use name_prefix so we don't end up with naming collisions.
resource "aws_security_group" "bcl_nitro" {
  name_prefix = "${var.instance_name}-sg-"
  description = "Security group for Bearclave Nitro Enclave enabled instances"

  tags = local.common_tags
}

# Allow ingress from anywhere on port 22 (typically used for SSH)
# trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "SSH on port 22"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}

# Allow ingress from anywhere on ports 80 and 8080 (typically used for HTTP)
resource "aws_vpc_security_group_ingress_rule" "http_80" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "HTTP on port 80"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}
resource "aws_vpc_security_group_ingress_rule" "http_8080" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "HTTP on port 8080"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}

# Allow ingress from anywhere on ports 443 and 8443 (typically used for HTTPS)
resource "aws_vpc_security_group_ingress_rule" "https_443" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "HTTPS on port 443"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}
resource "aws_vpc_security_group_ingress_rule" "https_8443" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "HTTPS on port 8443"
  from_port         = 8443
  to_port           = 8443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}

# Allow all egress traffic
# trivy:ignore:AVD-AWS-0104
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.bcl_nitro.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = local.common_tags
}
