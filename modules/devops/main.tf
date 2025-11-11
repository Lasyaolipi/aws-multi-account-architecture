# ECR Repository
resource "aws_ecr_repository" "main" {
  name = "${var.environment}-${var.project_name}-repository"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# CodeBuild for CI/CD (optional - can use GitHub Actions instead)
resource "aws_codebuild_project" "terraform" {
  name          = "${var.environment}-${var.project_name}-terraform"
  description   = "Terraform build project for ${var.environment}"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "10"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/your-username/aws-multi-account-architecture.git"
    git_clone_depth = 1
    buildspec       = <<EOF
version: 0.2
phases:
  install:
    commands:
      - curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
      - apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
      - apt-get update && apt-get install terraform
  build:
    commands:
      - cd environments/production
      - terraform init
      - terraform validate
      - terraform plan
EOF
  }

  tags = var.common_tags
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.environment}-${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.environment}-${var.project_name}-codebuild-role"
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.environment}-${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = ["*"]
        Action = [
          "s3:*",
          "ec2:*",
          "iam:*",
          "logs:*",
          "cloudwatch:*"
        ]
      }
    ]
  })
}