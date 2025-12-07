variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "bucket_suffix" {
  type    = string
  default = "app"
}

variable "enable_kms" {
  type    = bool
  default = true
  description = "Whether to create and use a KMS key for S3 encryption"
}

variable "kms_key_alias" {
  type    = string
  default = ""
  description = "Optional alias for the KMS key. If empty, an alias will be generated from project/env/suffix"
}
