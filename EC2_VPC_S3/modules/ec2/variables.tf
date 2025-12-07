variable "project" {
  type        = string
}

variable "env" {
  type        = string
}

variable "private_subnet_ids" {
  type        = list(string)
}

variable "vpc_id" {
  type        = string
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to access SSH/HTTP"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "ami_id" {
  type        = string
  description = "AMI id to use for EC2 instances"
}
