variable "project" {
  type    = string
  default = "demo-app"
}

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "enable_nat" {
  type    = bool
  default = true
}

variable "bucket_suffix" {
  type    = string
  default = "app"
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "10.0.0.0/8"
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
  type = string
}
