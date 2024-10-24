resource "aws_codedeploy_app" "ecomm-express-api" {
  compute_platform = "Server"
  name             = "ecomm-express-api"
}

resource "aws_codedeploy_deployment_group" "ecomm-express-api-dg" {
  app_name               = aws_codedeploy_app.ecomm-express-api.name
  deployment_group_name  = "ecomm-express-api-dg"
  service_role_arn       = aws_iam_role.CodeDeployAllowASGandEC2.arn
  deployment_style {
    deployment_type = "IN_PLACE"
  }
  autoscaling_groups = [aws_autoscaling_group.ecomm-api-asg.id]
}