variable "key-name" {
  
}

variable "security-group-name" {
  
}

variable "amazon-linux2-ami" {
  
}

variable "ubuntu-ami" {
  
}

variable "instances" {
    type = map(object({
      instance_type = string
      root_block_size = number
    }))
  
  default = {
    "jenkins-master" = {
        instance_type = "t2.micro"
        root_block_size = 10
    }
    "build-maven" = {
        instance_type = "t2.medium"
        root_block_size = 25
    }
    "ansible" = {
        instance_type = "t2.micro"
        root_block_size = 10
    }
  }
}