provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "demo-sg"

  ingress {
    description = "TLS from VPC"
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

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_instance" "demo-instance" {
    ami = var.amazon-linux2-ami
    instance_type = var.t2micro-instance-type
    key_name = var.key-name
    security_groups = [ "demo-sg" ]
    count = 1

    tags = {
      Name = "demo-instance"
    }
}
