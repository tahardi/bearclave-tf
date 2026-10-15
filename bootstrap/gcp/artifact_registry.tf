resource "google_artifact_registry_repository" "bearclave" {
  repository_id          = "bearclave"
  location               = var.region
  format                 = "DOCKER"
  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      tag_state  = "ANY"
      older_than = "604800s" # 7 days
    }
  }

  cleanup_policies {
    id     = "keep-releases"
    action = "KEEP"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["latest", "v"]
    }
  }

  depends_on = [google_project_service.this]
}
