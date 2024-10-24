resource "aws_codedeploy_app" "ecomm-express-api" {
  compute_platform = "Server"
  name             = "ecomm-express-api"
}

resource "aws_codedeploy_deployment_group" "ecomm-express-api-dg" {
  app_name               = aws_codedeploy_app.ecomm-express-api.name
  deployment_group_name  = "ecomm-express-api-dg"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.CodeDeployAllowASGandEC2.arn
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  autoscaling_groups = [aws_autoscaling_group.ecomm-api-asg.id]
}

////////////////////////////////////////////////////////////////////
// This section creates the pipeline //

//create connection to github
resource "aws_codestarconnections_connection" "ecomm-express-api-pl-conn" {
  name          = "ecomm-express-api-pl-conn"
  provider_type = "GitHub"
}

//create the pipeline
resource "aws_codepipeline" "ecomm-express-api-pl" {
  name     = "ecomm-express-api-pl"
  role_arn = aws_iam_role.CodePipelineRole.arn
  pipeline_type = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.ecomm-express-api-bucket.bucket
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
        ConnectionArn    = aws_codestarconnections_connection.ecomm-express-api-pl-conn.arn
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
        ApplicationName = "ecomm-express-api"
        DeploymentGroupName = "ecomm-express-api-dg"
      }
    }
  }
}