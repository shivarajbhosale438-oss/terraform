variable "project" {
  type        = string
  description = "Project name prefix for resources"
}

variable "env" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to use"
}

variable "enable_nat" {
  type        = bool
  description = "Whether to create a NAT gateway"
  default     = true
}
