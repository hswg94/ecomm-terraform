////////////////////////////////////////////////////////////////////
// Artifact Bucket

# This bucket is accessed by codepipeline to store ecomm-api
resource "aws_s3_bucket" "artifacts" {
  bucket        = var.artifact_bucket_name
  force_destroy = "true" //allow bucket to be deleted by terraform without removing files
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

////////////////////////////////////////////////////////////////////
// IAM

# CodeDeploy Role to access ASG and EC2
resource "aws_iam_role" "codedeploy" {
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

resource "aws_iam_role_policy_attachment" "codedeploy" {
  for_each = {
    AmazonEC2FullAccess   = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    AutoScalingFullAccess = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
    IAMFullAccess         = "arn:aws:iam::aws:policy/IAMFullAccess"
  }
  role       = aws_iam_role.codedeploy.id
  policy_arn = each.value
}

# CodePipeline Role
resource "aws_iam_role" "codepipeline" {
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

resource "aws_iam_role_policy" "codepipeline_connections" {
  name = "codeconnections-policy"
  role = aws_iam_role.codepipeline.id
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

resource "aws_iam_role_policy_attachment" "codepipeline" {
  for_each = {
    AWSCodeDeployFullAccess          = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
    AWSKeyManagementServicePowerUser = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
    AmazonS3FullAccess               = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  }
  role       = aws_iam_role.codepipeline.id
  policy_arn = each.value
}

////////////////////////////////////////////////////////////////////
// CodeDeploy

resource "aws_codedeploy_app" "api" {
  name             = "ecomm-api"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "api" {
  app_name               = aws_codedeploy_app.api.name
  deployment_group_name  = "ecomm-api-dg"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  service_role_arn       = aws_iam_role.codedeploy.arn
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  autoscaling_groups = [var.asg_name] # deploy to the ASG
}

////////////////////////////////////////////////////////////////////
// CodePipeline

resource "aws_codepipeline" "api" {
  name           = "ecomm-api-pl"
  role_arn       = aws_iam_role.codepipeline.arn
  pipeline_type  = "V2"     # Use V2 as it supports the queued execution mode
  execution_mode = "QUEUED" # Use QUEUED to allow multiple executions of the pipeline to queue up

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      category         = "Source"
      owner            = "AWS"
      name             = "ApplicationSource"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_code_artifact"]
      configuration = {
        ConnectionArn    = var.connection_arn
        FullRepositoryId = var.repository_id
        BranchName       = "main"
        DetectChanges    = "true"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      owner           = "AWS"
      name            = "ApplicationDeploy"
      provider        = "CodeDeploy"
      input_artifacts = ["source_code_artifact"]
      version         = "1"
      configuration = {
        ApplicationName     = aws_codedeploy_app.api.name
        DeploymentGroupName = aws_codedeploy_deployment_group.api.deployment_group_name
      }
    }
  }
}
