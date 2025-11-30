variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "AdityaKadam"
}

variable "github_repo" {
  type = string
  description = "https://github.com/Adi-Kadam-07/Static-Web-Deployment--Terra-Jen.git"
}
