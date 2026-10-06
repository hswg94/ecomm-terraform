output "codebuild_project_name" {
  description = "Name of the frontend CodeBuild project"
  value       = aws_codebuild_project.frontend.name
}
