/*
  Backend configuration (S3 + DynamoDB for state locking).

  NOTE: Terraform backend blocks cannot use variables directly. Provide
  values when running `terraform init` using `-backend-config` flags or
  a backend configuration file. Example:

  terraform init \
    -backend-config="bucket=your-terraform-state-bucket" \
    -backend-config="key=state/${terraform.workspace}/infra.tfstate" \
    -backend-config="dynamodb_table=your-lock-table" \
    -backend-config="region=ap-south-1"

  The repository also contains `variables.tf` documenting the required
  backend variables for convenience.
*/

terraform {
  backend "s3" {}
}
