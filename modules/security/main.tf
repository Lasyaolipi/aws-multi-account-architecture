# AWS GuardDuty
resource "aws_guardduty_detector" "main" {
  count = var.enable_guardduty ? 1 : 0
  enable = true

  tags = var.common_tags
}

# AWS Security Hub
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count     = var.enable_security_hub ? 1 : 0
  depends_on = [aws_securityhub_account.main[0]]
  
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

# AWS Config
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.environment}-${var.project_name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.environment}-${var.project_name}-config-delivery"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# S3 Bucket for Config logs
resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.environment}-${var.project_name}-config-bucket-${var.aws_region}"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-config-bucket"
  })
}

resource "aws_s3_bucket_acl" "config_bucket_acl" {
  bucket = aws_s3_bucket.config_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# SNS Topic for Security Alerts
resource "aws_sns_topic" "security_alerts" {
  name = "${var.environment}-${var.project_name}-security-alerts"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-security-alerts"
  })
}

# IAM Role for Config
resource "aws_iam_role" "config_role" {
  name = "${var.environment}-${var.project_name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-config-role"
  })
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}