output "project_number" {
  description = "GCP project number"
  value       = data.google_project.this.number
}

output "workload_identity_provider" {
  description = "Workload identity provider resource name for google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_service_account_email" {
  description = "Service account GitHub Actions impersonates"
  value       = google_service_account.github.email
}

output "vm_service_account_email" {
  description = "Service account attached to Bearclave VMs"
  value       = google_service_account.vm.email
}

output "registry" {
  description = "Artifact Registry Docker repository path"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/bearclave"
}
