mock_provider "aws" {}

override_resource {
  target          = aws_iam_openid_connect_provider.github
  override_during = plan
  values = {
    arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }
}

variables {
  eif_bucket_name   = "bearclave-test-eifs"
  ci_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test"
  budget_email      = "test@example.com"
}

run "trust_policy_scoped" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.github_actions.assume_role_policy).Statement[0].Condition.StringLike["token.actions.githubusercontent.com:sub"] == "repo:tahardi/bearclave-examples:*"
    error_message = "Role must only trust the bearclave-examples repository"
  }

  assert {
    condition     = jsondecode(aws_iam_role.github_actions.assume_role_policy).Statement[0].Condition.StringEquals["token.actions.githubusercontent.com:aud"] == "sts.amazonaws.com"
    error_message = "Role must only trust tokens issued for STS"
  }
}

run "bucket_private" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.eif.block_public_acls,
      aws_s3_bucket_public_access_block.eif.block_public_policy,
      aws_s3_bucket_public_access_block.eif.ignore_public_acls,
      aws_s3_bucket_public_access_block.eif.restrict_public_buckets,
    ])
    error_message = "EIF bucket must block all public access"
  }
}

run "bucket_lifecycle" {
  command = plan

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.eif.rule[0].filter[0].tag[0].key == "preserve"
    error_message = "Lifecycle rule must filter on the preserve tag"
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.eif.rule[0].filter[0].tag[0].value == "false"
    error_message = "Lifecycle rule must match preserve=false"
  }

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.eif.rule[0].expiration[0].days == 7
    error_message = "Lifecycle rule must expire objects after seven days"
  }
}

run "budget_notifications" {
  command = plan

  assert {
    condition = toset([
      for n in aws_budgets_budget.this.notification : "${n.notification_type}/${n.threshold}"
      ]) == toset([
      "ACTUAL/50",
      "ACTUAL/90",
      "ACTUAL/100",
      "FORECASTED/100",
    ])
    error_message = "Budget must notify at 50, 90 and 100 percent actual and 100 percent forecasted"
  }

  assert {
    condition     = length(aws_budgets_budget.this.notification) == 4
    error_message = "Budget must have four notifications"
  }
}
