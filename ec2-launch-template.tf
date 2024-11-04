#ec2 launch template
resource "aws_launch_template" "ecomm-api-lt" {
  name = "ecomm-api-lt"
  description   = "launch template for ecomm-api deployment to ec2, use with auto scaling groups"
  instance_type = "t2.micro"
  image_id      = "ami-04b6019d38ea93034" //Amazon Linux 2023

  # IAM role for EC2 instance
  iam_instance_profile {
    name = aws_iam_instance_profile.EC2AccessSMandCDInstanceProfile.id
  }

  # Security Group reference
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]

  # Optional: User data script
  user_data = filebase64("./userdata.sh")
}
