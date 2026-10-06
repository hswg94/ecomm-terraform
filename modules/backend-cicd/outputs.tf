output "pipeline_name" {
  description = "Name of the backend CodePipeline"
  value       = aws_codepipeline.api.name
}

output "artifact_bucket_name" {
  description = "Name of the CodePipeline artifact bucket"
  value       = aws_s3_bucket.artifacts.bucket
}
