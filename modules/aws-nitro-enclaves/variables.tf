variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-2"
}

variable "instance_name" {
  description = "The name of the EC2 instance (must be unique)."
  type        = string
}

variable "key_pair_name" {
  description = "The name of an existing SSH keypair in AWS. Note that this must exist in the same region as the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type. Must be Nitro-capable. Common options: c5.xlarge, c5a.xlarge, m5.large, m5.xlarge"
  type        = string
  default     = "c5.xlarge"
}

# Amazon Machine Image ID (AMI ID) identifies the virtual machine image to
# boot the EC2 instance with.
variable "ami_id" {
  description = "The AMI ID to use. Defaults to Amazon Linux 2023 in us-east-2."
  type        = string
  default     = "ami-06f1fc9ae5ae7f31e"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}