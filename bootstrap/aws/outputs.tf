output "github_role_arn" {
  description = "ARN of the role GitHub Actions assumes"
  value       = aws_iam_role.github_actions.arn
}

output "eif_bucket_name" {
  description = "Name of the S3 bucket that stores EIFs"
  value       = aws_s3_bucket.eif.bucket
}

output "key_pair_name" {
  description = "Name of the EC2 key pair CI uses for SSH"
  value       = aws_key_pair.ci.key_name
}
