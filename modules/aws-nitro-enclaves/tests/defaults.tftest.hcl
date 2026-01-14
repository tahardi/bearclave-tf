run "configuration_validation" {
  command = plan

  variables {
    instance_name = "test-nitro-instance"
    ami_id        = "ami-0c55b159cbfafe1f0"
    instance_type = "m7i.xlarge"
    key_pair_name = "ec2-key--tahardi-bearclave"
    aws_region    = "us-east-2"
    tags          = {}
  }

  assert {
    condition     = aws_instance.bcl_nitro.ami == var.ami_id
    error_message = "Instance AMI must match input variable"
  }

  assert {
    condition     = aws_instance.bcl_nitro.instance_type == var.instance_type
    error_message = "Instance type must match input variable"
  }

  assert {
    condition     = aws_instance.bcl_nitro.key_name == var.key_pair_name
    error_message = "Key pair name must match input variable"
  }

  assert {
    condition     = aws_instance.bcl_nitro.key_name == var.key_pair_name
    error_message = "Key pair name must match input variable"
  }
}

run "security_settings" {
  command = plan

  variables {
    instance_name = "test-nitro-instance"
    ami_id        = "ami-0c55b159cbfafe1f0"
    instance_type = "m7i.xlarge"
    key_pair_name = "ec2-key--tahardi-bearclave"
    aws_region    = "us-east-2"
    tags          = {}
  }

  assert {
    condition     = aws_instance.bcl_nitro.enclave_options[0].enabled == true
    error_message = "Enclave must be enabled"
  }

  assert {
    condition     = aws_instance.bcl_nitro.metadata_options[0].http_endpoint == "enabled"
    error_message = "Metadata service must be enabled"
  }

  assert {
    condition     = aws_instance.bcl_nitro.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 must require tokens"
  }

  assert {
    condition     = aws_instance.bcl_nitro.metadata_options[0].http_put_response_hop_limit == 1
    error_message = "Metadata hop limit must be 1"
  }

  assert {
    condition     = aws_instance.bcl_nitro.metadata_options[0].instance_metadata_tags == "enabled"
    error_message = "Instance metadata tags must be enabled"
  }

  assert {
    condition     = aws_instance.bcl_nitro.root_block_device[0].encrypted == true
    error_message = "Root volume must be encrypted"
  }

  assert {
    condition     = aws_instance.bcl_nitro.root_block_device[0].volume_type == "gp3"
    error_message = "Root volume must be gp3 type"
  }
}

run "tagging_strategy" {
  command = plan

  variables {
    instance_name = "test-nitro-instance"
    ami_id        = "ami-0c55b159cbfafe1f0"
    instance_type = "m7i.xlarge"
    key_pair_name = "ec2-key--tahardi-bearclave"
    aws_region    = "us-east-2"
    tags = {
      Environment = "dev"
      Owner       = "platform-team"
    }
  }

  assert {
    condition     = aws_instance.bcl_nitro.tags["Name"] == "test-nitro-instance"
    error_message = "Instance must have Name tag matching instance_name"
  }

  assert {
    condition     = aws_instance.bcl_nitro.tags["Environment"] == "dev"
    error_message = "Instance must inherit Environment tag"
  }

  assert {
    condition     = aws_instance.bcl_nitro.tags["Owner"] == "platform-team"
    error_message = "Instance must inherit Owner tag"
  }

  assert {
    condition     = aws_security_group.bcl_nitro.tags["Name"] == "test-nitro-instance"
    error_message = "Security group must have Name tag matching instance_name"
  }

  assert {
    condition     = aws_security_group.bcl_nitro.tags["Environment"] == "dev"
    error_message = "Security group must inherit Environment tag"
  }
}

run "security_group_rules" {
  command = plan

  variables {
    instance_name = "test-nitro-instance"
    ami_id        = "ami-0c55b159cbfafe1f0"
    instance_type = "m7i.xlarge"
    key_pair_name = "ec2-key--tahardi-bearclave"
    aws_region    = "us-east-2"
    tags          = {}
  }

  # Verify ingress rules exist
  assert {
    condition     = aws_vpc_security_group_ingress_rule.ssh.from_port == 22
    error_message = "SSH ingress rule (port 22) must exist"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.http_80.from_port == 80
    error_message = "HTTP ingress rule (port 80) must exist"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.http_8080.from_port == 8080
    error_message = "HTTP alternative ingress rule (port 8080) must exist"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.https_443.from_port == 443
    error_message = "HTTPS ingress rule (port 443) must exist"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.https_8443.from_port == 8443
    error_message = "HTTPS alternative ingress rule (port 8443) must exist"
  }

  # Verify CIDR blocks for ingress
  assert {
    condition     = aws_vpc_security_group_ingress_rule.ssh.cidr_ipv4 == "0.0.0.0/0"
    error_message = "SSH rule must allow traffic from anywhere"
  }

  # Verify egress rules
  assert {
    condition     = aws_vpc_security_group_egress_rule.allow_all.ip_protocol == "-1"
    error_message = "Egress rule must allow all protocols"
  }

  assert {
    condition     = aws_vpc_security_group_egress_rule.allow_all.cidr_ipv4 == "0.0.0.0/0"
    error_message = "Egress rule must allow all destinations"
  }
}

run "dependency_validation" {
  command = plan

  variables {
    instance_name = "test-nitro-instance"
    ami_id        = "ami-0c55b159cbfafe1f0"
    instance_type = "m7i.xlarge"
    key_pair_name = "ec2-key--tahardi-bearclave"
    aws_region    = "us-east-2"
    tags          = {}
  }

  assert {
    condition     = aws_instance.bcl_nitro.key_name == data.aws_key_pair.this.key_name
    error_message = "Instance key name must match the data source key pair"
  }

  assert {
    condition     = data.aws_key_pair.this.key_name == var.key_pair_name
    error_message = "Key pair data source must reference the correct key name"
  }
}
