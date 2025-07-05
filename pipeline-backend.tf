////////////////////////////////////////////////////////////////////
// This section creates the pipeline //

# CodeStar Connection is NOT allowed to be established through the CLI.
# Create a CodeStar Connnection through the AWS UI, then store it as a variable in terraform cloud.
# Lastly, import the 'connection_arn' variable from HCP terraform
variable "connection_arn" {
  type        = string
  description = "This is a connection arn for CodePipeline to authenticate with GitHub"
  sensitive   = false
}

//create the pipeline
resource "aws_codepipeline" "ecomm-api-pl" {
  name     = "ecomm-api-pl"
  role_arn = aws_iam_role.CodePipelineRole.arn
  pipeline_type = "V2" # Use V2 as it supports the queued execution mode
  execution_mode = "QUEUED" # Use QUEUED to allow multiple executions of the pipeline to queue up

  artifact_store {
    location = aws_s3_bucket.ecomm-api-s3-for-cp.bucket
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
        FullRepositoryId = "hswg94/ecomm-express-api"
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
        ApplicationName = aws_codedeploy_app.ecomm-api.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ecomm-api-dg.deployment_group_name
      }
    }
  }
}

resource "aws_codedeploy_deployment_group" "ecomm-api-dg" {
  app_name               = aws_codedeploy_app.ecomm-api.name
  deployment_group_name  = "ecomm-api-dg"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  service_role_arn       = aws_iam_role.CodeDeployRole.arn
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  autoscaling_groups = [aws_autoscaling_group.ecomm-api-asg.id] # deploy to the ASG
}

resource "aws_codedeploy_app" "ecomm-api" {
  name             = "ecomm-api"
  compute_platform = "Server"
}