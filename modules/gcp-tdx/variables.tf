variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "bearclave"
}

variable "zone" {
  description = "GCP Zone for the instance"
  type        = string
  default     = "us-central1-a"
}

variable "service_account_email" {
  description = "Email of the Service Account you wish to attach to the VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for accessing instance"
  type        = string
  sensitive   = true
}

variable "instance_name" {
  description = "Name of the compute instance (must be unique)."
  type        = string
}

variable "machine_type" {
  description = "Machine type (e.g., c3-standard-8)"
  type        = string
  default     = "c3-standard-8"
}

variable "container_image" {
  description = "Container image URI from Artifact Registry"
  type        = string
  default     = "hello-world"
}

variable "labels" {
  description = "Labels to apply to the instance"
  type        = map(string)
  default     = {}
}
