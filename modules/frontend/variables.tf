variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket that holds the built frontend"
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone for the frontend records"
}

variable "certificate_arn" {
  type        = string
  description = "Validated ACM certificate (us-east-1) for CloudFront"
}

variable "frontend_domain" {
  type        = string
  description = "Hostname of the frontend, e.g. ecomm.hswg94.com"
}
