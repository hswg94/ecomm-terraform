# Create VPC
resource "aws_vpc" "MyFypVpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyFypVpc"
  }
}

# Create Internet Gateway and place in the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.MyFypVpc.id
  tags = {
    Name = "MyFypVpc-igw"
  }
}

# Create 2 Public Subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.MyFypVpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true  # Enable public IPs
  tags = {
    Name = "MyFypVpc-public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.MyFypVpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true  # Enable public IPs
  tags = {
    Name = "MyFypVpc-public-subnet-2"
  }
}

# Create Route Table for routing traffic to the Internet Gateway
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.MyFypVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "MyFypVpc-public-rt"
  }
}

# Associate the route table to the subnets
resource "aws_route_table_association" "public-subnet-association-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-subnet-association_2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}