output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "ec2_private_ips" {
  value = module.ec2.instance_private_ips
}

output "app_bucket_name" {
  value = module.s3.bucket_name
}
