variable "bucket_name" {
  type        = string
  description = "S3 bucket the build output is written to"
}

variable "connection_arn" {
  type        = string
  description = "CodeConnections (CodeStar) connection ARN used to pull from GitHub"
}

variable "repository_url" {
  type        = string
  description = "HTTPS URL of the frontend GitHub repository"
}
