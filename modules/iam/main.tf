# IAM Roles for different services
resource "aws_iam_role" "devops_role" {
  name = "${var.environment}-${var.project_name}-devops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-devops-role"
  })
}

resource "aws_iam_role_policy_attachment" "devops_ec2_full" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "devops_s3_full" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Role for GitHub Actions
resource "aws_iam_user" "github_actions" {
  name = "${var.environment}-${var.project_name}-github-actions"
  path = "/service-accounts/"

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-github-actions"
  })
}

resource "aws_iam_user_policy" "github_actions" {
  name = "${var.environment}-${var.project_name}-github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "ec2:*",
          "iam:*",
          "rds:*",
          "lambda:*",
          "cloudwatch:*",
          "logs:*",
          "guardduty:*",
          "securityhub:*",
          "config:*",
          "dynamodb:*",
          "ecr:*",
          "codebuild:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}