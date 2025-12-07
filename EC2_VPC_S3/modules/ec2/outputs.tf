output "instance_ids" {
  description = "EC2 instance IDs"
  value       = [for i in aws_instance.app : i.id]
}

output "instance_private_ips" {
  description = "Private IPs of the instances"
  value       = [for i in aws_instance.app : i.private_ip]
}

output "security_group_id" {
  description = "Security group for instances"
  value       = aws_security_group.instance_sg.id
}
