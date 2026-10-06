variable "vpc_id" {
  type        = string
  description = "VPC for the security groups and target group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the ALB and the Auto Scaling Group"
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone for the API records"
}

variable "certificate_arn" {
  type        = string
  description = "Validated ACM certificate (ap-southeast-1) for the HTTPS listener"
}

variable "api_domain" {
  type        = string
  description = "Hostname of the API, e.g. api.hswg94.com"
}
