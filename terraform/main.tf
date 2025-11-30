terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# Security Group for HTTP & SSH
resource "aws_security_group" "web_sg" {
  name        = "static-web-sg"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Web-SG"
  }
}

# EC2 instance creation
resource "aws_instance" "web_server" {
  ami                    = "data.aws_ami.ubuntu.id"        # Ubuntu 22.04 LTS (ap-south-1)
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = templatefile("${path.module}/user_data.tpl", {
    repo_url = var.github_repo
  })

  tags = {
    Name = "Terraform-Static-Web-Server"
  }
}

# Output Public IP
output "public_ip" {
  description = "EC2 Public IP for accessing the website"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web_server.public_ip}"
}
