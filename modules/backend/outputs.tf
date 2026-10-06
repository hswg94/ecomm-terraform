output "asg_name" {
  description = "Name of the Auto Scaling Group that CodeDeploy deploys to"
  value       = aws_autoscaling_group.api.name
}

output "alb_dns_name" {
  description = "AWS-assigned DNS name of the ALB"
  value       = aws_lb.api.dns_name
}

output "api_url" {
  description = "Public URL of the API"
  value       = "https://${aws_route53_record.api.fqdn}"
}
