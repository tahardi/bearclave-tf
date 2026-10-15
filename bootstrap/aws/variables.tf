variable "aws_region" {
  description = "AWS region for regional resources"
  type        = string
  default     = "us-east-2"
}

variable "github_repository" {
  description = "GitHub repository, as owner/name, allowed to assume the GitHub Actions role"
  type        = string
  default     = "tahardi/bearclave-examples"
}

variable "eif_bucket_name" {
  description = "Globally unique name of the S3 bucket that stores EIFs"
  type        = string
}

variable "ci_ssh_public_key" {
  description = "Public key CI uses to SSH into Nitro hosts"
  type        = string
}

variable "budget_email" {
  description = "Email address that receives budget alerts"
  type        = string
  sensitive   = true
}

variable "monthly_budget_usd" {
  description = "Monthly budget in USD"
  type        = number
  default     = 10
}
