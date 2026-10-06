variable "domain_name" {
  type        = string
  description = "Domain registered in Route 53, e.g. hswg94.com"
}

variable "api_domain" {
  type        = string
  description = "Hostname of the backend API; its wildcard is added to the ALB certificate"
}

variable "frontend_domain" {
  type        = string
  description = "Hostname of the frontend; its wildcard is added to the CloudFront certificate"
}
