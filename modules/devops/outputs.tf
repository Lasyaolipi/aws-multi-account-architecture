output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.main.arn
}

output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = aws_codebuild_project.terraform.name
}