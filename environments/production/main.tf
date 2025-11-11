terraform {
  backend "s3" {
    bucket         = "production-multi-account-arch-terraform-state-ap-south-1"
    key            = "production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "production-multi-account-arch-terraform-locks"
    encrypt        = true
  }
}
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# Local variables for tagging
locals {
  common_tags = {
    Environment = var.environment
    Project     = "Multi-Account-Arch"
    ManagedBy   = "Terraform"
    Owner       = "Lasyaolipi"
    Repository  = "https://github.com/${var.github_owner}/${var.github_repo}"
  }

  name_prefix = "${var.environment}-${var.project_name}"
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project_name = var.project_name
  aws_region   = var.aws_region
  common_tags  = local.common_tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  environment  = var.environment
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.availability_zones
  common_tags  = local.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"

  environment         = var.environment
  project_name        = var.project_name
  aws_region          = var.aws_region
  aws_account_id      = var.aws_account_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = var.enable_security_hub
  common_tags         = local.common_tags
}

# DevOps Module
module "devops" {
  source = "../../modules/devops"

  environment        = var.environment
  project_name       = var.project_name
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  common_tags        = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  environment   = var.environment
  project_name  = var.project_name
  aws_region    = var.aws_region
  common_tags   = local.common_tags
  sns_topic_arn = module.security.security_sns_topic_arn
}