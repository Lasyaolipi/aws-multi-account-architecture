output "devops_role_arn" {
  description = "ARN of the DevOps IAM role"
  value       = aws_iam_role.devops_role.arn
}

output "github_actions_access_key" {
  description = "GitHub Actions IAM access key"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_key" {
  description = "GitHub Actions IAM secret key"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}