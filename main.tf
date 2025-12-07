locals {
  name_prefix = "${var.project}-${var.env}"
}

module "vpc" {
  source = "./modules/vpc"
  project = var.project
  env     = var.env
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
  enable_nat = var.enable_nat
}

module "s3" {
  source = "./modules/s3"
  project = var.project
  env     = var.env
  bucket_suffix = var.bucket_suffix
}

module "ec2" {
  source = "./modules/ec2"
  project = var.project
  env     = var.env
  vpc_id  = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  allowed_ssh_cidr = var.allowed_ssh_cidr
  instance_type = var.instance_type
  instance_count = var.instance_count
  ami_id = var.ami_id
}
