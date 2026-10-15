mock_provider "google" {}

variables {
  project_id         = "bearclave-test"
  billing_account_id = "000000-000000-000000"
}

run "workload_identity_restricted_to_repos" {
  command = plan

  assert {
    condition     = google_iam_workload_identity_pool_provider.github.attribute_condition == "assertion.repository in ['tahardi/bearclave-examples']"
    error_message = "Pool provider must only trust the default repository"
  }
}

run "workload_identity_restricted_to_listed_repos" {
  command = plan

  variables {
    github_repositories = ["a/b", "c/d"]
  }

  assert {
    condition     = google_iam_workload_identity_pool_provider.github.attribute_condition == "assertion.repository in ['a/b', 'c/d']"
    error_message = "Pool provider must only trust the listed repositories"
  }
}

run "github_sa_roles" {
  command = plan

  assert {
    condition = toset([for m in google_project_iam_member.github : m.role]) == toset([
      "roles/compute.instanceAdmin.v1",
      "roles/compute.securityAdmin",
      "roles/artifactregistry.writer",
      "roles/logging.viewer",
    ])
    error_message = "GitHub service account must have exactly the four expected roles"
  }
}

run "registry_cleanup" {
  command = plan

  assert {
    condition     = length(google_artifact_registry_repository.bearclave.cleanup_policies) == 2
    error_message = "Registry must have two cleanup policies"
  }

  assert {
    condition = anytrue([
      for p in google_artifact_registry_repository.bearclave.cleanup_policies :
      p.action == "DELETE" && p.condition[0].older_than == "604800s"
    ])
    error_message = "Registry must delete images older than seven days"
  }

  assert {
    condition = anytrue([
      for p in google_artifact_registry_repository.bearclave.cleanup_policies :
      p.action == "KEEP" && toset(p.condition[0].tag_prefixes) == toset(["latest", "v"])
    ])
    error_message = "Registry must keep images tagged latest or v"
  }
}

run "budget_thresholds" {
  command = plan

  assert {
    condition = toset([
      for r in google_billing_budget.this.threshold_rules : "${r.threshold_percent}/${r.spend_basis}"
      ]) == toset([
      "0.5/CURRENT_SPEND",
      "0.9/CURRENT_SPEND",
      "1/CURRENT_SPEND",
      "1/FORECASTED_SPEND",
    ])
    error_message = "Budget must alert at 50, 90 and 100 percent of spend and 100 percent of forecast"
  }

  assert {
    condition     = length(google_billing_budget.this.threshold_rules) == 4
    error_message = "Budget must have four threshold rules"
  }
}
