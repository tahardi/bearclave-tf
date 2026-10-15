resource "google_service_account" "github" {
  account_id   = "bearclave-github"
  display_name = "Bearclave GitHub Actions"
  depends_on   = [google_project_service.this]
}

resource "google_service_account" "vm" {
  account_id   = "bearclave-vm"
  display_name = "Bearclave VM"
  depends_on   = [google_project_service.this]
}

resource "google_project_iam_member" "github" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/compute.securityAdmin",
    "roles/artifactregistry.writer",
    "roles/logging.viewer",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github.email}"
}

resource "google_project_iam_member" "vm" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.vm.email}"
}

resource "google_service_account_iam_member" "github_uses_vm" {
  service_account_id = google_service_account.vm.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github.email}"
}
