locals {
  name_prefix = "${var.project}-${var.env}"
  tags = {
    Project     = var.project
    Environment = var.env
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for application instances"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH and HTTP from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-sg" })
}

resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y || true
              if command -v yum >/dev/null 2>&1; then
                yum update -y || true
                yum install -y nginx || true
                systemctl enable nginx || true
                systemctl start nginx || true
              else
                apt-get install -y nginx || true
                systemctl enable nginx || true
                systemctl start nginx || true
              fi
              echo "<html><body><h1>${var.env} - ${var.project}</h1></body></html>" > /var/www/html/index.html
            EOF

  tags = merge(local.tags, { Name = "${local.name_prefix}-instance-${count.index}" })
}

output "instance_ids" {
  value = [for i in aws_instance.app : i.id]
}

output "instance_private_ips" {
  value = [for i in aws_instance.app : i.private_ip]
}

output "security_group_id" {
  value = aws_security_group.instance_sg.id
}
