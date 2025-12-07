output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key (if created)"
  value       = var.enable_kms ? aws_kms_key.this[0].arn : ""
}

output "kms_key_id" {
  description = "KMS key id (if created)"
  value       = var.enable_kms ? aws_kms_key.this[0].key_id : ""
}
