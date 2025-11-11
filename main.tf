# This is the root module that can be used for local development
provider "aws" {
  region = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# Local variables for tagging
locals {
  common_tags = {
    Environment   = var.environment
    Project       = "Multi-Account-Arch"
    ManagedBy     = "Terraform"
    Owner         = "Lasyaolipi"
    Repository    = "https://github.com/${var.github_owner}/${var.github_repo}"
  }
  
  name_prefix = "${var.environment}-${var.project_name}"
}

# S3 Bucket for Terraform State (created first)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.name_prefix}-terraform-state-${var.aws_region}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-terraform-state"
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB for Terraform locks
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "${local.name_prefix}-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-terraform-locks"
  })
}