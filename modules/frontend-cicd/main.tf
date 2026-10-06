////////////////////////////////////////////////////////////////////
// IAM

# CodeBuild Role
resource "aws_iam_role" "codebuild" {
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

resource "aws_iam_role_policy" "codebuild_connections" {
  name = "codeconnections-policy"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : ["codestar-connections:UseConnection"],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:codestar-connections:*:*:connection/*",
          "arn:aws:codeconnections:*:*:connection/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  for_each = {
    AWSKeyManagementServicePowerUser = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
    AmazonS3FullAccess               = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    CloudWatchLogsFullAccess         = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }
  role       = aws_iam_role.codebuild.id
  policy_arn = each.value
}

////////////////////////////////////////////////////////////////////
// CodeBuild

# Account-wide GitHub credential for CodeBuild, backed by the CodeConnections connection
resource "aws_codebuild_source_credential" "github" {
  auth_type   = "CODECONNECTIONS"
  server_type = "GITHUB"
  token       = var.connection_arn
}

resource "aws_codebuild_project" "frontend" {
  name         = "ecomm-frontend-builder"
  description  = "This builds the ecomm-frontend and place it in S3 bucket"
  service_role = aws_iam_role.codebuild.arn

  source { # This is the location of the source code for the build
    type      = "GITHUB"
    location  = var.repository_url
    buildspec = file("${path.module}/buildspec.yaml") # This is the buildspec file that contains the build commands and settings
  }

  environment { # This is the serverless specification for running codebuild
    type                        = "LINUX_LAMBDA_CONTAINER"
    compute_type                = "BUILD_LAMBDA_4GB"
    image_pull_credentials_type = "CODEBUILD"
    image                       = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
  }

  artifacts {
    type                = "S3"
    location            = var.bucket_name
    name                = "/"  # This is the path in the S3 bucket where the build files will be stored.
    encryption_disabled = true # This is set to true because the build files are static webpages that need to be read by cloudfront
    packaging           = "NONE"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  # CodeBuild rejects a GitHub source until the account has a GitHub credential
  depends_on = [aws_codebuild_source_credential.github]
}

# the terraform_data resource is used to trigger CodeBuild on initial setup
resource "terraform_data" "initial_build" {
  triggers_replace = aws_codebuild_project.frontend.id
  // The runtime is executed from Terraform Cloud so it's required to set an AWS_DEFAULT_REGION Environment Variable there.
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.frontend.name}"
  }

  # The first build needs the role's permissions in place to pull the source and write to S3
  depends_on = [
    aws_iam_role_policy.codebuild_connections,
    aws_iam_role_policy_attachment.codebuild,
  ]
}
