terraform {
  cloud {
    organization = "computing-project"
    workspaces {
      name = "aws-project-workspace"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# # Create VPC
# resource "aws_vpc" "MyFypVpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "MyFypVpc"
#   }
# }

# # Create Internet Gateway and place in the VPC
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.MyFypVpc.id
#   tags = {
#     Name = "MyFypVpc-igw"
#   }
# }

# # Create 2 Public Subnets
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id                  = aws_vpc.MyFypVpc.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "ap-southeast-1a"
#   tags = {
#     Name = "MyFypVpc-public-subnet-1"
#   }
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id                  = aws_vpc.MyFypVpc.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = "ap-southeast-1b"
#   tags = {
#     Name = "MyFypVpc-public-subnet-2"
#   }
# }

## Create Route Table for routing traffic to the Internet Gateway
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.MyFypVpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = {
#     Name = "MyFypVpc-public-rt"
#   }
# }

# # Associate the route table with the subnets
# resource "aws_route_table_association" "public_subnet_association_1" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_rt.id
# }

# resource "aws_route_table_association" "public_subnet_association_2" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_rt.id
# }

### Create EC2 Instance
# resource "aws_instance" "ec2-1" {
#   ami                         = "ami-0ad522a4a529e7aa8"
#   instance_type               = "t2.micro"
#   iam_instance_profile        = aws_iam_instance_profile.AllowEC2AccessSM.name
#   vpc_security_group_ids      = ["sg-04a6d76079170ea62"]
#   subnet_id                   = "subnet-06cb493de5b519bdf"
#   associate_public_ip_address = true
#   user_data                   = file("./userdata.sh")

#   tags = {
#     Name = "ecomm-express-api"
#   }
# }

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
