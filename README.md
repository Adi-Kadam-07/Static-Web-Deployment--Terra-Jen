# Static Website on EC2 Using Terraform Jenkins Deployment :

## Description :
This project demonstrates how to deploy a **static website** on an **AWS EC2 instance** using **Terraform** for infrastructure automation and **Jenkins** for continuous updates. The website is served using **Nginx** or **Apache**, and any changes pushed to the GitHub repository are automatically deployed through a **Jenkins pipeline using GitHub webhooks.**

## Project Architecture :
GitHub Repository → Jenkins CI/CD Pipeline → EC2 Instance (Nginx) → End Users
       ↑                    ↓                      ↓
   Webhook Trigger     SSH Deployment      Static Website Serving
---

## Tools & Technologies :

- AWS EC2 – Virtual server for hosting the website.

- Terraform – Infrastructure as Code (IaC) tool.

- Jenkins – CI/CD automation tool.

- GitHub – Version control and webhook integration.

- Nginx / Apache – Web server to serve static content.

- Bash / User Data – Automated instance setup.

## Project Workflow :

- Static Website Repo Clone To Local Machine

- Push updates to GitHub.

- GitHub webhook triggers Jenkins pipeline.

- Jenkins pulls updates and deploys to EC2.

- EC2 web server serves the updated website.
---

 ## Terraform Requirements :
 -  Create an EC2 instance
 - Create a Security Group allowing HTTP traffic
 -  Use User Data to install Nginx/Apache and clone the repo into /var/www/html
 - Set proper file permissions
 
 
 ```
 Main.tf

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



```
**Example Terraform steps :**
1. Write Terraform configuration for EC2 and Security Group.
2. Apply Terraform:  
   ```bash
   terraform init
   terraform plan
   terraform apply


 ## User Data script to :
  - Install **Nginx** or **Apache** web server.
  - Clone the project repository into `/var/www/html`.
  - Set proper **file permissions** for the web content.

``` /bin/bash
set -e

apt-get update -y
apt-get install -y git nginx

rm -rf /var/www/html/*
git clone ${repo_url} /tmp/site || true

if [ -d /tmp/site/website ]; then
  cp -r /tmp/site/website/* /var/www/html/
else
  cp -r /tmp/site/* /var/www/html/
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

systemctl enable nginx
systemctl restart nginx
```

## Jenkins CI/CD Pipeline Setup :

- **Trigger:** GitHub Webhook (on `push` events).
- **Pipeline Stages:**
  1. **Pull latest code** from GitHub.
  2. **SSH into EC2** instance.
  3. **Pull updates** into `/var/www/html`.
  4. **Restart Nginx/Apache** to apply changes.

- **jenkinsfile :**

```pipeline {
    agent any
    environment {
        EC2_USER = "ubuntu"                       // EC2 username
        EC2_HOST = "65.1.111.60"                  // EC2 public IP
        REMOTE_DIR = "/var/www/html"              // Deployment directory
        SSH_CREDENTIAL_ID = "ec2-ssh-key"         // Jenkins SSH credential ID
        GIT_REPO = "https://github.com/Adi-Kadam-07/Static-Web-Deployment--Terra-Jen.git" // Your repo
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy to EC2 via SSH') {
            steps {
                sshagent([env.SSH_CREDENTIAL_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'bash -s' <<ENDSSH
                        set -e

                        # Mark the directory as safe for Git
                        git config --global --add safe.directory ${REMOTE_DIR}

                        # Ensure deployment directory exists
                        sudo mkdir -p ${REMOTE_DIR}

                        # Pull latest changes if repo exists, else clone
                        if [ -d ${REMOTE_DIR}/.git ]; then
                            sudo git -C ${REMOTE_DIR} pull origin main || true
                        else
                            sudo git clone ${GIT_REPO} ${REMOTE_DIR}
                        fi

                        # Fix permissions for Nginx
                        sudo chown -R www-data:www-data ${REMOTE_DIR}
                        sudo chmod -R 755 ${REMOTE_DIR}

                        # Ensure index.html exists
                        if [ ! -f ${REMOTE_DIR}/index.html ]; then
                            echo '<h1>Deployment successful!</h1>' | sudo tee ${REMOTE_DIR}/index.html
                        fi

                        # Restart Nginx
                        sudo systemctl restart nginx
ENDSSH
                    """
                }
            }
        }

        stage('Validation') {
            steps {
                echo "Deployment finished. Open http://${EC2_HOST}/ to check your website."
            }
        }
    }
}
```
- ## Jenkins Job :
![](/img/static_jenkin_job_done.png)

 ## **Trigger:** GitHub Webhook (on `push` events) :

 ![](/img/github_webhook.png)

 ## **Instance Servers :**
 ![](/img/static_servers.png)

 ## Project Output :
**A static website is hosted on an AWS EC2 instance (Nginx/Apache) provisioned via Terraform.
When changes are pushed to the GitHub repository, a Jenkins pipeline (triggered by a webhook) automatically pulls the latest code, updates the EC2 web root, restarts the web server, and the live site instantly reflects the new changes.**

![](/img/static_output.png)

## Conclusion :

#### This project showcases the power of combining Infrastructure as Code (Terraform) with Continuous Integration and Continuous Deployment (Jenkins) to build a fully automated deployment pipeline. By provisioning the EC2 instance and its dependencies through Terraform, the infrastructure remains consistent, repeatable, and version-controlled.

#### The integration of GitHub webhooks with Jenkins ensures that any code changes are deployed to production within seconds, eliminating manual intervention and reducing the risk of human error. Using Nginx/Apache as the web server provides a lightweight, reliable, and high-performance platform for serving static content>####
