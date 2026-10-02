terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
    region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "five-server-vpc"
  cider = "10.0.0.0/16"

  azs = [
    "ap-south-1a"
    "ap-south-1b"
  ]

  public_subnets = [
    "10.0.1.0/24"
    "10.0.2.0/24"
  ]

  enable_nat_gateway = false
}

resource "aws_security_group" "server_sg" {
    name = "five-server-sg"
    vpc_id = module.vpc.vpc_id

    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocal    = "tcp"

      cider_blocks = [""]
    }
    
    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocal    = "tcp"

      cider_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port   = 0
      protocal  = "-1"

      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "five-server-sg"
    }
}

resource "aws_instance" "server" {
    count = 5 
    ami        = " "
    instance_type = "t3.micro"

    subnet_id = module.vpc.public_subnets [
        count.index % length(module.vpc.public_subnets)
    ]

    vpc_security_group_id = [
        aws_Security_group_server_sg.id 
    ]

    key_name = ""

    tags = {
      Name = "server-${count.index + 1}"
    }
}

output "server_public_ips" {
  values = aws_instance.server[*].public_ip
}

output "server_private_ips" {
    values = aws_instance.server[*].private_ip
}