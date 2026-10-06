output "frontend_url" {
  description = "Public URL of the frontend"
  value       = module.frontend.url
}

output "api_url" {
  description = "Public URL of the API"
  value       = module.backend.api_url
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID, needed for cache invalidations"
  value       = module.frontend.distribution_id
}

output "cloudfront_domain_name" {
  description = "AWS-assigned domain name of the CloudFront distribution"
  value       = module.frontend.cloudfront_domain_name
}

output "alb_dns_name" {
  description = "AWS-assigned DNS name of the API load balancer"
  value       = module.backend.alb_dns_name
}

output "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = module.dns.zone_id
}

output "route53_name_servers" {
  description = "Name servers of the hosted zone"
  value       = module.dns.name_servers
}

output "frontend_bucket_name" {
  description = "S3 bucket that holds the built frontend"
  value       = module.frontend.bucket_name
}

output "pipeline_artifact_bucket" {
  description = "S3 bucket CodePipeline stores artifacts in"
  value       = module.backend_cicd.artifact_bucket_name
}

output "codepipeline_name" {
  description = "Name of the backend CodePipeline"
  value       = module.backend_cicd.pipeline_name
}

output "codebuild_project_name" {
  description = "Name of the frontend CodeBuild project"
  value       = module.frontend_cicd.codebuild_project_name
}

output "asg_name" {
  description = "Name of the API Auto Scaling Group"
  value       = module.backend.asg_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}
