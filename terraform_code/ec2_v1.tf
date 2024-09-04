provider "aws" {
  region = "ap-south-1"
}

data "aws_security_group" "SSH" {
    id = "sg-0977d3fe2183374d7"
}

resource "aws_instance" "demo-instance" {
    ami = var.amazon-linux2-ami
    instance_type = var.t2micro-instance-type
    key_name = var.key-name
    vpc_security_group_ids = [data.aws_security_group.SSH.id]
    count = 1

    tags = {
      Name = "demo-instance"
    }
}