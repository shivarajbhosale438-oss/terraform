locals {
  raw_name = "${var.project}-${var.env}-app-${var.bucket_suffix}"
  bucket_name = lower(replace(local.raw_name, "/[^a-zA-Z0-9-]/", "-"))
  tags = {
    Project     = var.project
    Environment = var.env
  }
}


data "aws_caller_identity" "current" {}

locals {
  bucket_arn = "arn:aws:s3:::${local.bucket_name}"
  bucket_object_arn = "arn:aws:s3:::${local.bucket_name}/*"
  kms_alias_name = var.kms_key_alias != "" ? var.kms_key_alias : lower("alias/${var.project}-${var.env}-${var.bucket_suffix}")
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  versioning {
    enabled = true
  }

  tags = merge(local.tags, { Name = local.bucket_name })

  lifecycle_rule {
    enabled = true
    abort_incomplete_multipart_upload_days = 7
  }
}

# Create a KMS key and alias and attach a policy that allows S3 to use it for this bucket
resource "aws_kms_key" "this" {
  count = var.enable_kms ? 1 : 0

  description             = "KMS key for S3 bucket ${local.bucket_name}"
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowAccountAdminsFullAccess"
        Effect = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action = "kms:*"
        Resource = "*"
      },
      {
        Sid = "AllowS3ServiceUseForThisBucket"
        Effect = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = { "aws:SourceArn" = [ local.bucket_arn, local.bucket_object_arn ] }
          StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "this" {
  count = var.enable_kms ? 1 : 0
  name  = local.kms_alias_name
  target_key_id = aws_kms_key.this[0].key_id
}

# If KMS enabled, configure SSE-KMS; otherwise fallback to SSE-S3
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.enable_kms ? [1] : [1]
    content {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.enable_kms ? "aws:kms" : "AES256"
        kms_master_key_id = var.enable_kms ? aws_kms_key.this[0].arn : null
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}
