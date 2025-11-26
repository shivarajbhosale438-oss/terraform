terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-south-1" # Mumbai
}

# Security Group allowing SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "example" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Amazon Linux 2 (ap-south-1) — replace as needed
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "MyEC2Instance"
  }
}

# Output public IP
output "public_ip" {
  value = aws_instance.example.public_ip
}

# Output instance ID
output "instance_id" {
  value = aws_instance.example.id
}
