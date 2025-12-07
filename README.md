# Terraform infrastructure for demo-app

This folder contains Terraform code (modules + root) to create a VPC, EC2 instances, and an S3 application bucket.

Prerequisites
- Terraform >= 1.6.0
- AWS credentials available via environment / profile / role
- An S3 bucket and DynamoDB table for Terraform remote state (create manually or via bootstrap)

Quick start
1. Initialize with backend config (example):
```powershell
terraform init \
  -backend-config="bucket=your-tf-state-bucket" \
  -backend-config="key=state/${terraform.workspace}/infra.tfstate" \
  -backend-config="dynamodb_table=your-lock-table" \
  -backend-config="region=ap-south-1"
```
2. Select or create workspace:
```powershell
terraform workspace new dev
terraform workspace select dev
```
3. Plan and apply (dev):
```powershell
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

Notes
- No credentials are stored in code.
- Backend values must be supplied at init time.
- Modules are in `modules/` and follow the `project` + `env` naming convention.
