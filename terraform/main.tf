provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "web_sg" {
  name        = "static-web-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0c02fb55956c7d316"   # Ubuntu 22.04 LTS ap-south-1
  instance_type          = "t2.micro"
  key_name               = "AdityaKadam"
  vpc_security_group_ids = [aws_security_group.static-web-sg.id]

  user_data = templatefile("${path.module}/user_data.tpl", {
    repo_url = "https://github.com/Adi-Kadam-07/Static-Web-Deployment--Terra-Jen.git"
  })

  tags = {
    Name = "Terraform-Static-Web-Server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}
