resource "aws_codedeploy_app" "ecomm-api" {
  compute_platform = "Server"
  name             = "ecomm-api"
}

resource "aws_codedeploy_deployment_group" "ecomm-api-dg" {
  app_name               = aws_codedeploy_app.ecomm-api.name
  deployment_group_name  = "ecomm-api-dg"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.CodeDeployAllowASGandEC2.arn
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  autoscaling_groups = [aws_autoscaling_group.ecomm-api-asg.id]
}

////////////////////////////////////////////////////////////////////
// This section creates the pipeline //

//create connection to github (Authentication with the connection provider MUST BE completed in the AWS Console)
# resource "aws_codestarconnections_connection" "ecomm-api-pl-conn" {
#   name          = "ecomm-api-pl-conn"
#   provider_type = "GitHub"
# }

//create the pipeline
resource "aws_codepipeline" "ecomm-api-pl" {
  name     = "ecomm-api-pl"
  role_arn = aws_iam_role.CodePipelineRole.arn
  pipeline_type = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.ecomm-api-bucket.bucket
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
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = "arn:aws:codeconnections:ap-southeast-1:971422707089:connection/b9f056f7-5e7b-411b-b1b6-5bf1cde49b35" // create this in UI
        FullRepositoryId = "hswg94/ecomm-express-api"
        BranchName       = "main"
        DetectChanges = "true"
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
      input_artifacts = ["source_output"]
      version         = "1"
      configuration = {
        ApplicationName = aws_codedeploy_app.ecomm-api.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ecomm-api-dg.deployment_group_name
      }
    }
  }
}