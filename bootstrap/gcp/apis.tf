resource "google_project_service" "this" {
  for_each = toset([
    "compute",
    "artifactregistry",
    "iam",
    "iamcredentials",
    "sts",
    "cloudresourcemanager",
    "logging",
    "billingbudgets",
  ])

  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
}
