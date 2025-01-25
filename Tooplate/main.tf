provider "aws" {
  region = "us-east-1" # Replace with your preferred AWS region
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "my-key-pair"           # Replace with your key pair name

  # Copy local files to the EC2 instance and configure NGINX
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx unzip
    systemctl start nginx
    systemctl enable nginx
    echo "Deploying Tooplate template..."
    mkdir -p /tmp/tooplate
    cat <<EOT > /tmp/template.zip
    $(base64 -w 0 /path/to/your/template.zip)
    EOT
    echo "Extracting Tooplate template..."
    echo "$base64_encoded_content" | base64 --decode > /tmp/template.zip
    unzip /tmp/template.zip -d /usr/share/nginx/html/
    systemctl restart nginx
  EOF

  tags = {
    Name = "Tooplate-Web-Server"
  }

  # Allow HTTP traffic to the instance
  vpc_security_group_ids = [aws_security_group.allow_http.id]
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

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
