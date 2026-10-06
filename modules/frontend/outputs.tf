output "bucket_name" {
  description = "Name of the S3 bucket that holds the built frontend"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "AWS-assigned domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "url" {
  description = "Public URL of the frontend"
  value       = "https://${aws_route53_record.frontend.fqdn}"
}
