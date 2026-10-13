resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "bearclave-github"
  display_name              = "Bearclave GitHub"
  depends_on                = [google_project_service.this]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository in [${join(", ", [for r in var.github_repositories : "'${r}'"])}]"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_workload_identity" {
  for_each = toset(var.github_repositories)

  service_account_id = google_service_account.github.name
  role               = "roles/iam.workloadIdentityUser"
  member = join("/", [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}",
    "attribute.repository/${each.key}",
  ])
}
