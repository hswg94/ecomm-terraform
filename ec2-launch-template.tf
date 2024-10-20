#ec2 launch template
resource "aws_launch_template" "ecomm-api-lt" {
  name = "ecomm-api-lt"
  description   = "A launch template containing ecomm-express-api deployment to ec2 for use with auto scaling groups"
  instance_type = "t2.micro"
  image_id      = "ami-0ad522a4a529e7aa8" //Amazon Linux 2023

  # IAM role for EC2 instance
  iam_instance_profile {
    name = aws_iam_instance_profile.AllowEC2AccessSM.id
  }

  # Security Group reference
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  # Optional: User data script
  user_data = filebase64("./userdata.sh")
}