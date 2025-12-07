variable "aws_region" {
  type    = string
  default = "ap-south-1"
  description = "AWS region to deploy into"
}

provider "aws" {
  region = var.aws_region
}
