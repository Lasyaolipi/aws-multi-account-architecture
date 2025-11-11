# AWS GuardDuty - Only create if enabled and available
resource "aws_guardduty_detector" "main" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true

  tags = var.common_tags

  # Add lifecycle to ignore subscription errors
  lifecycle {
    ignore_changes = [enable]
  }
}

# AWS Security Hub - Only create if enabled and available
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0

  # Add lifecycle to ignore subscription errors
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  count      = var.enable_security_hub ? 1 : 0
  depends_on = [aws_securityhub_account.main[0]]

  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  # Add lifecycle to ignore subscription errors
  lifecycle {
    ignore_changes = all
  }
}

# AWS Config - Fixed configuration
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
  s3_key_prefix  = "config" # Add key prefix

  depends_on = [aws_s3_bucket_policy.config_bucket]
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

# S3 Bucket for Config logs - Remove ACL and add proper policy
resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.environment}-${var.project_name}-config-bucket-${var.aws_region}"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-config-bucket"
  })
}

resource "aws_s3_bucket_versioning" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for AWS Config
resource "aws_s3_bucket_policy" "config_bucket" {
  bucket = aws_s3_bucket.config_bucket.id
  policy = data.aws_iam_policy_document.config_bucket.json
}

data "aws_iam_policy_document" "config_bucket" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.config_bucket.arn]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.config_bucket.arn}/config/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
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

# Add managed policy for S3 access
resource "aws_iam_role_policy_attachment" "config_s3_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}