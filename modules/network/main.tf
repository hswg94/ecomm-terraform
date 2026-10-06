locals {
  # The key is the subnet number used in the Name tag
  public_subnets = {
    "1" = { cidr_block = "10.0.1.0/24", availability_zone = "ap-southeast-1a" }
    "2" = { cidr_block = "10.0.2.0/24", availability_zone = "ap-southeast-1b" }
  }
}

# Create VPC
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyFypVpc"
  }
}

# Create Internet Gateway and place in the VPC
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "MyFypVpc-igw"
  }
}

# Create 2 Public Subnets
resource "aws_subnet" "public" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true # Enable public IPs
  tags = {
    Name = "MyFypVpc-public-subnet-${each.key}"
  }
}

# Create Route Table for routing traffic to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "MyFypVpc-public-rt"
  }
}

# Associate the route table to the subnets
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
