output "zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Name servers of the hosted zone"
  value       = aws_route53_zone.this.name_servers
}

# Both certificate outputs come from the validation resources, so anything using them waits until the certificate is issued
output "alb_certificate_arn" {
  description = "ARN of the validated ALB certificate (ap-southeast-1)"
  value       = aws_acm_certificate_validation.alb.certificate_arn
}

output "cloudfront_certificate_arn" {
  description = "ARN of the validated CloudFront certificate (us-east-1)"
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}
