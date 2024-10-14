terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

resource "aws_instance" "ec2-1" {
  ami                    = "ami-0ad522a4a529e7aa8"
  instance_type          = "t2.micro"
  iam_instance_profile   = "ReadFromSecretsManager"
  vpc_security_group_ids = ["sg-04a6d76079170ea62"]
  subnet_id              = "subnet-06cb493de5b519bdf"
  associate_public_ip_address = true
  user_data              = file("./userdata.sh")
  tags = {
    Name = "ecomm-express-api"
  }
}

# resource "aws_instance" "ec2_2" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   vpc_security_group_ids = var.vpc_security_group_ids
#   subnet_id              = var.subnet_id
#   associate_public_ip_address = true
#   tags = {
#     Name = "EC2Instance2"
#   }
# }
