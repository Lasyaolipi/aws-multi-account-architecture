# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.environment}/${var.project_name}/application"
  retention_in_days = 30

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "security" {
  name              = "/${var.environment}/${var.project_name}/security"
  retention_in_days = 90

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/${var.environment}/${var.project_name}/audit"
  retention_in_days = 365

  tags = var.common_tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.environment}-${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-1234567890abcdef0"]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization"
        }
      }
    ]
  })

}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [var.sns_topic_arn]

  tags = var.common_tags
}