resource "aws_codebuild_source_credential" "codebuild-credentials" {
  auth_type   = "CODECONNECTIONS"
  server_type = "GITHUB"
  token       = var.connection_arn
}

resource "aws_codebuild_project" "ecomm-frontend-builder" {
  name         = "ecomm-frontend-builder"
  description  = "This builds the ecomm-frontend and place it in S3 bucket"
  service_role = aws_iam_role.CodeBuildRole.arn

  source { # This is the location of the source code for the build
    type      = "GITHUB"
    location  = "https://github.com/hswg94/ecomm-react-frontend"
    buildspec = file("buildspec.yaml") # This is the buildspec file that contains the build commands and settings
  }

  environment { # This is the serverless specification for running codebuild
    type                        = "LINUX_LAMBDA_CONTAINER"
    compute_type                = "BUILD_LAMBDA_4GB"
    image_pull_credentials_type = "CODEBUILD"
    image                       = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
  }

  artifacts {
    type                = "S3"
    location            = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.bucket
    name                = "/" # This is the path in the S3 bucket where the build files will be stored.
    encryption_disabled = true # This is set to true because the build files are static webpages that need to be read by cloudfront
    packaging           = "NONE"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}


# the terraform_data resource is used to trigger CodeBuild on initial setup
resource "terraform_data" "initial_codebuild_trigger" {
  triggers_replace = aws_codebuild_project.ecomm-frontend-builder.id
  // The runtime is executed from Terraform Cloud so it's required to set an AWS_DEFAULT_REGION Environment Variable there.
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.ecomm-frontend-builder.name}"
  }
}
