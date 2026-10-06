variable "artifact_bucket_name" {
  type        = string
  description = "Name of the S3 bucket CodePipeline stores artifacts in"
}

variable "connection_arn" {
  type        = string
  description = "CodeConnections (CodeStar) connection ARN used to pull from GitHub"
}

variable "repository_id" {
  type        = string
  description = "GitHub repository of the API, as owner/name"
}

variable "asg_name" {
  type        = string
  description = "Auto Scaling Group that CodeDeploy deploys to"
}
