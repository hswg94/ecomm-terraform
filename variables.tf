# connection_arn and the two bucket names are set as 'Terraform Variables' in the HCP Terraform workspace.

# CodeStar Connection is NOT allowed to be established through the CLI.
# Create a CodeStar Connnection through the AWS UI, then store it as a variable in terraform cloud.
variable "connection_arn" {
  type        = string
  description = "This is a connection arn for CodePipeline and CodeBuild to authenticate with GitHub"
  sensitive   = false
}

# This bucket is accessed by codepipeline to store ecomm-api
variable "ecomm-api-s3-for-cp" {
  type        = string
  description = "The S3 bucket name for AWS CodePipeline"
  sensitive   = false

  validation {
    condition = alltrue([
      can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.ecomm-api-s3-for-cp)),
      !strcontains(var.ecomm-api-s3-for-cp, ".."),
      !can(regex("^[0-9]+(\\.[0-9]+){3}$", var.ecomm-api-s3-for-cp)),
      !can(regex("^(xn--|sthree-|amzn-s3-demo-)", var.ecomm-api-s3-for-cp)),
      !can(regex("(-s3alias|--ol-s3|--x-s3|--table-s3|\\.mrap)$", var.ecomm-api-s3-for-cp)),
    ])
    error_message = "Must be a valid S3 bucket name: 3-63 lowercase letters, numbers, dots or hyphens, starting and ending with a letter or number."
  }
}

# This bucket is accessed by codebuild and cloudfront
variable "ecomm-frontend-s3-for-cb-and-cf" {
  type        = string
  description = "The S3 bucket name used to store codebuild artifacts and accessed by cloudfront"
  sensitive   = false

  validation {
    condition = alltrue([
      can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.ecomm-frontend-s3-for-cb-and-cf)),
      !strcontains(var.ecomm-frontend-s3-for-cb-and-cf, ".."),
      !can(regex("^[0-9]+(\\.[0-9]+){3}$", var.ecomm-frontend-s3-for-cb-and-cf)),
      !can(regex("^(xn--|sthree-|amzn-s3-demo-)", var.ecomm-frontend-s3-for-cb-and-cf)),
      !can(regex("(-s3alias|--ol-s3|--x-s3|--table-s3|\\.mrap)$", var.ecomm-frontend-s3-for-cb-and-cf)),
    ])
    error_message = "Must be a valid S3 bucket name: 3-63 lowercase letters, numbers, dots or hyphens, starting and ending with a letter or number."
  }
}

variable "domain_name" {
  type        = string
  description = "Domain registered in Route 53. The API is served at api.<domain> and the frontend at ecomm.<domain>"
  default     = "hswg94.com"
}
