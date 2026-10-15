# Versioning is not needed: the bucket holds build artifacts that CI can rebuild and deletes after 7 days.
# trivy:ignore:AVD-AWS-0090
resource "aws_s3_bucket" "eif" {
  bucket = var.eif_bucket_name
}

resource "aws_s3_bucket_public_access_block" "eif" {
  bucket                  = aws_s3_bucket.eif.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# AWS-managed AES256 encryption is enough for short-lived build artifacts; a KMS key adds cost and key management.
# trivy:ignore:AVD-AWS-0132
resource "aws_s3_bucket_server_side_encryption_configuration" "eif" {
  bucket = aws_s3_bucket.eif.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "eif" {
  bucket = aws_s3_bucket.eif.id

  rule {
    id     = "expire-unpreserved"
    status = "Enabled"

    filter {
      tag {
        key   = "preserve"
        value = "false"
      }
    }

    expiration {
      days = 7
    }
  }

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}
