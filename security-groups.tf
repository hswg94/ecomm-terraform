resource "aws_security_group" "ec2-sg" {
  name        = "ec2-sg"
  description = "Allow HTTP and ICMP traffic"
  vpc_id      = aws_vpc.MyFypVpc.id

  ingress {
    description = "Allow HTTP from ALB only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb-sg.id] # Restrict to ALB SG
  }

  # Inbound rules
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP traffic from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (allow all by default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}


resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow HTTPS and ICMP traffic to the ALB"
  vpc_id      = aws_vpc.MyFypVpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}
