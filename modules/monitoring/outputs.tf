output "cloudwatch_log_groups" {
  description = "CloudWatch log group names"
  value = {
    application = aws_cloudwatch_log_group.application.name
    security    = aws_cloudwatch_log_group.security.name
    audit       = aws_cloudwatch_log_group.audit.name
  }
}

output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}