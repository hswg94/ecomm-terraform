# Import the 'Terraform Variable' from HCP terraform
variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub Token for CodeBuild"
  sensitive   = true
}

# Create the CodeBuild Source Credential
resource "aws_codebuild_source_credential" "codebuild-credentials" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.GITHUB_TOKEN
}

resource "aws_codebuild_webhook" "ecomm-frontend-builder-webhook" {
  project_name = aws_codebuild_project.ecomm-frontend-builder.name
  build_type   = "BUILD"
}

resource "aws_codebuild_project" "ecomm-frontend-builder" {
  name         = "ecomm-frontend-builder"
  description  = "This builds the ecomm-frontend and place it in S3 bucket"
  service_role = aws_iam_role.CodeBuildRole.arn

  source {
    type      = "GITHUB"
    location  = "https://github.com/hswg94/ecomm-react-frontend"
    buildspec = file("buildspec.yaml")
  }

  environment {
    type                        = "LINUX_LAMBDA_CONTAINER"
    compute_type                = "BUILD_LAMBDA_4GB"
    image_pull_credentials_type = "CODEBUILD"
    image                       = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"
  }

  artifacts {
    type                = "S3"
    location            = aws_s3_bucket.ecomm-frontend-s3-for-cb-and-cf.bucket
    name                = "/"
    encryption_disabled = true
    packaging           = "NONE"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}


# terraform_data resource to trigger CodeBuild on initial setup
resource "terraform_data" "initial_codebuild_trigger" {
  triggers_replace = aws_codebuild_project.ecomm-frontend-builder.id
  //must set AWS_DEFAULT_REGION in HCP Terraform as env var as the runtime executed from terraform cloud
  provisioner "local-exec" {
    command = "aws codebuild start-build --project-name ${aws_codebuild_project.ecomm-frontend-builder.name}"
  }
}
