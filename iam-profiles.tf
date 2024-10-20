# Create IAM Role
resource "aws_iam_role" "AllowEC2AccessSM" {
  name = "AllowEC2AccessSM"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach Secrets Manager read/write permission to the role
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.AllowEC2AccessSM.id
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "AllowEC2AccessSM" {
  name = "AllowEC2AccessSM"
  role = aws_iam_role.AllowEC2AccessSM.name
}