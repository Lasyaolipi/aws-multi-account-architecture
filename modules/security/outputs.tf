output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = var.enable_guardduty ? aws_guardduty_detector.main[0].id : null
}

output "security_hub_status" {
  description = "Security Hub status"
  value       = var.enable_security_hub ? "ENABLED" : "DISABLED"
}

output "config_recorder_name" {
  description = "Config recorder name"
  value       = aws_config_configuration_recorder.main.name
}

output "security_sns_topic_arn" {
  description = "Security SNS topic ARN"
  value       = aws_sns_topic.security_alerts.arn
}