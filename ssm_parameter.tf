resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "cloudwatch-agent-config"
  type  = "String"
  value = file("cloudwatch-agent-config.json")
}