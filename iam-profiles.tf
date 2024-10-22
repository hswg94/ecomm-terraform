# Create IAM Role to allow EC2 to access Secrets Manager and CodeDeploy
resource "aws_iam_role" "EC2AccessSMandCDRole" {
  name = "EC2AccessSMandCDRole"
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
resource "aws_iam_role_policy_attachment" "AttachSecretsManagerReadWritePolicy" {
  role       = aws_iam_role.EC2AccessSMandCDRole.id
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "AttachCodeDeployServiceRolePolicy" {
  role       = aws_iam_role.EC2AccessSMandCDRole.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# Create IAM Instance Profile by joining the permission and the role
resource "aws_iam_instance_profile" "EC2AccessSMandCDInstanceProfile" {
  name = "EC2AccessSMandCDInstanceProfile"
  role = aws_iam_role.EC2AccessSMandCDRole.name
}

///////////////////////////////////////////////////////////////////////

