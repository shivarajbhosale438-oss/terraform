# Project: AWS VPC + EC2 + S3 using Terraform (Multi-module)
You are an AI coding assistant. Your job is to generate **Terraform code** for the tasks below.
Use **Terraform 1.6+** and follow best practices for **multi-module** projects.
---
## Tech stack & conventions
- IaC: Terraform
- Provider: AWS
- Region: `ap-south-1`
- State: Remote state in S3 with DynamoDB locking
- Modules:
  - `vpc`
  - `ec2`
  - `s3`
- Environments: `dev` and `prod` (separate workspaces or tfvars)
Project structure (create if missing):
/terraform
/modules
/vpc
main.tf
variables.tf
outputs.tf
/ec2
main.tf
variables.tf
outputs.tf
/s3
main.tf
variables.tf
outputs.tf
/envs
dev.tfvars
prod.tfvars
main.tf
providers.tf
variables.tf
outputs.tf
backend.tf
versions.tf
README.md


Global rules:
- Use **Terraform AWS provider** version `~> 5.0`.
- No hardcoded credentials; assume env/role-based auth.
- All modules must:
  - Define `variables.tf` with proper types & descriptions.
  - Define `outputs.tf` with meaningful outputs.
- Name resources with a `project` and `env` prefix, for example: `project = "demo-app"`, `env = "dev"`, resource name: `demo-app-dev-vpc`.
---
## Task 1: Define Terraform versions & providers
**Goal:** Set up the basic Terraform configuration and AWS provider.
Files to create/update:
- `terraform/versions.tf`
- `terraform/providers.tf`
Requirements:
1. In `versions.tf`:
   - Set minimum Terraform version to `>= 1.6.0`.
   - Require AWS provider: `~> 5.0`.
2. In `providers.tf`:
   - Configure AWS provider with:
     - Region variable: `var.aws_region` with default `ap-south-1`.
   - Support multiple workspaces (`terraform.workspace`) to distinguish envs if needed.
Acceptance criteria:
- `terraform init` works without errors (assuming provider/plugin download allowed).
- `terraform validate` passes.
---
## Task 2: Configure remote backend (S3 + DynamoDB)
**Goal:** Store Terraform state remotely in an S3 bucket with DynamoDB lock.
Files:
- `terraform/backend.tf`
Requirements:
1. Use `terraform` backend `s3` with variables for:
   - `bucket`
   - `dynamodb_table`
   - `region`
   - `key` (include workspace in the key, e.g. `state/${terraform.workspace}/infra.tfstate`)
2. Do **not** create the S3 bucket and DynamoDB table inside this same config (assume they exist or are created manually / by bootstrap).
3. Document required backend resources in `README.md`.
Acceptance criteria:
- Backend configuration uses variables and is not hardcoded except default region.
- Clear comments on how to set `backend` values when running `terraform init -backend-config=...`.
---
## Task 3: VPC module
**Goal:** Create a reusable VPC module.
Module path:
- `terraform/modules/vpc`
Resources:
- 1 VPC
- Public and private subnets across 2 AZs
- Internet Gateway
- Public route table with default route to IGW
- NAT Gateway for private subnets (1 NAT in a public subnet is enough)
Variables (in `variables.tf`):
- `project` (string)
- `env` (string)
- `vpc_cidr` (string)
- `public_subnets` (list(string))
- `private_subnets` (list(string))
- `azs` (list(string))
- `enable_nat` (bool, default = true)
Outputs (in `outputs.tf`):
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
Acceptance criteria:
- `terraform validate` passes for the module.
- All resources are tagged with `Project`, `Environment`, and `Name`.
---
## Task 4: EC2 module
**Goal:** Launch EC2 instances in the **private subnets** created by the VPC module.
Module path:
- `terraform/modules/ec2`
Resources:
- Security group allowing:
  - Inbound: HTTP (80), SSH (22) from a configurable CIDR
  - Outbound: All traffic
- One or more EC2 instances in private subnets, using:
  - AMI ID as a variable
  - Instance type as a variable (default: `t3.micro`)
  - User data script to install Nginx and serve a simple index page with env name.
Variables:
- `project` (string)
- `env` (string)
- `private_subnet_ids` (list(string))
- `vpc_id` (string)
- `allowed_ssh_cidr` (string)
- `instance_type` (string, default `t3.micro`)
- `instance_count` (number, default `1`)
- `ami_id` (string)
Outputs:
- `instance_ids`
- `instance_private_ips`
- `security_group_id`
Acceptance criteria:
- Instances are launched in private subnets.
- User data renders an `index.html` that includes the environment name (e.g., "dev" or "prod").
---
## Task 5: S3 module for app bucket
**Goal:** Create an S3 bucket with secure defaults.
Module path:
- `terraform/modules/s3`
Resources:
- S3 bucket with:
  - Versioning enabled
  - Block public access
  - Server-side encryption (SSE-S3 at minimum)
Variables:
- `project` (string)
- `env` (string)
- `bucket_suffix` (string, optional, to make bucket name unique)
Outputs:
- `bucket_name`
- `bucket_arn`
Acceptance criteria:
- Bucket name pattern: `${project}-${env}-app-${bucket_suffix}` (ensure lower-case, replace invalid chars).
- No public ACLs or policies allowed.
---
## Task 6: Root module wiring
**Goal:** Use the modules (`vpc`, `ec2`, `s3`) from the root configuration.
Files:
- `terraform/main.tf`
- `terraform/variables.tf`
- `terraform/outputs.tf`
- `terraform/envs/dev.tfvars`
- `terraform/envs/prod.tfvars`
Requirements:
1. In `variables.tf`, define:
   - `project` (string, default `"demo-app"`)
   - `env` (string)
   - `aws_region` (string, default `ap-south-1`)
   - `vpc_cidr`, `public_subnets`, `private_subnets`, `azs`
   - Any other variables needed by modules.
2. In `main.tf`:
   - Call `module "vpc"` with appropriate variables.
   - Call `module "s3"` with `project`, `env`, and a suffix.
   - Call `module "ec2"`:
     - Use `module.vpc.vpc_id` and `module.vpc.private_subnet_ids`.
     - Wire other required variables.
3. In `envs/dev.tfvars` and `envs/prod.tfvars`:
   - Provide realistic CIDR blocks and subnets.
   - Set `env = "dev"` and `env = "prod"` respectively.
4. In `outputs.tf`:
   - Expose:
     - `vpc_id`
     - `public_subnet_ids`
     - `private_subnet_ids`
     - `ec2_private_ips`
     - `app_bucket_name`
Acceptance criteria:
- `terraform validate` in the root directory passes.
- `terraform plan -var-file=envs/dev.tfvars` shows resources for VPC, EC2, and S3 correctly.
---
## Task 7: Documentation
**Goal:** Provide clear usage documentation.
File:
- `terraform/README.md`
Requirements:
Include:
1. Prerequisites:
   - Terraform version
   - AWS credentials (IAM role/profile)
   - Existing S3 + DynamoDB for backend
2. How to run:
   - `terraform init -backend-config=...`
   - `terraform workspace new dev` / `select dev` (if using workspaces)
   - `terraform plan -var-file=envs/dev.tfvars`
   - `terraform apply -var-file=envs/dev.tfvars`
3. How to destroy:
   - `terraform destroy -var-file=envs/dev.tfvars`
4. Description of modules and their outputs.
Acceptance criteria:
- README is accurate and matches the actual files and variables.
- A new engineer can follow steps and deploy `dev` environment.
---
## Final checklist
Before considering the tasks done, ensure:
- [ ] `terraform fmt` has been run on all files.
- [ ] `terraform validate` passes.
- [ ] Root module and all child modules have `variables.tf` and `outputs.tf`.
- [ ] No hardcoded secrets or credentials.
- [ ] Resource names and tags follow the `project` + `env` naming convention.
