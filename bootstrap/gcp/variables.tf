variable "project_id" {
  description = "GCP project ID to bootstrap"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "us-east1"
}

variable "billing_account_id" {
  description = "Billing account ID that owns the project budget"
  type        = string
  sensitive   = true
}

variable "github_repositories" {
  description = "GitHub repositories, as owner/name, allowed to impersonate the GitHub service account"
  type        = list(string)
  default     = ["tahardi/bearclave-examples"]
}

variable "monthly_budget_usd" {
  description = "Monthly budget in USD"
  type        = number
  default     = 10
}
