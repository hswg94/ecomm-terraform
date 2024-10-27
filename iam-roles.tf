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

resource "aws_iam_role_policy_attachment" "AttachSecretsManagerReadWritePolicy" {
  role       = aws_iam_role.EC2AccessSMandCDRole.id
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "AttachCodeDeployServiceRolePolicy" {
  role       = aws_iam_role.EC2AccessSMandCDRole.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "EC2AccessSMandCDInstanceProfile" {
  name = "EC2AccessSMandCDInstanceProfile"
  role = aws_iam_role.EC2AccessSMandCDRole.name
}

///////////////////////////////////////////////////////////////////////

# CodeDeploy Role to access ASG and EC2 
resource "aws_iam_role" "CodeDeployRole" {
  name = "CodeDeployRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codedeploy.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "AttachAmazonEC2FullAccess" {
  role       = aws_iam_role.CodeDeployRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "AttachAutoScalingFullAccess" {
  role       = aws_iam_role.CodeDeployRole.id
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_role_policy_attachment" "AttachIAMFullAccess" {
  role       = aws_iam_role.CodeDeployRole.id
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}


///////////////////////////////////////////////////////////////////////

# CodePipeline Role
resource "aws_iam_role" "CodePipelineRole" {
  name = "CodePipelineRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "AttachCodeConnectionsToCodePipeline" {
  name = "codeconnections-policy"
  role = aws_iam_role.CodePipelineRole.id
  policy = file("codestar-connections-policy.json")
}

resource "aws_iam_role_policy_attachment" "AttachCodeDeploytoCodePipeline" {
  role       = aws_iam_role.CodePipelineRole.id
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

resource "aws_iam_role_policy_attachment" "AttachKMStoCodePipeline" {
  role       = aws_iam_role.CodePipelineRole.id
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "AttachS3toCodePipeline" {
  role       = aws_iam_role.CodePipelineRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

//////////////////////////////////////////////////////////////////

# CodeBuild Role
resource "aws_iam_role" "CodeBuildRole" {
  name = "CodeBuildRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "AttachCodeConnectionsToCodeBuild" {
  name = "codeconnections-policy"
  role = aws_iam_role.CodeBuildRole.id
  policy = file("codestar-connections-policy.json")
}

resource "aws_iam_role_policy_attachment" "AttachKMStoCodeBuild" {
  role       = aws_iam_role.CodeBuildRole.id
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}

resource "aws_iam_role_policy_attachment" "AttachS3toCodeBuild" {
  role       = aws_iam_role.CodeBuildRole.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "AttachCloudWatchLogstoCodeBuild" {
  role       = aws_iam_role.CodeBuildRole.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}