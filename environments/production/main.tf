# Backend configuration for production environment
terraform {
  backend "s3" {
    bucket         = "production-multi-account-arch-terraform-state-ap-south-1"
    key            = "production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "production-multi-account-arch-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Data source for EKS cluster auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# Local variables for tagging
locals {
  common_tags = {
    Environment = var.environment
    Project     = "Multi-Account-Arch"
    ManagedBy   = "Terraform"
    Owner       = "Lavakumar"
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

# EKS Module
module "eks" {
  source = "../../modules/eks"

  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  vpc_cidr           = var.vpc_cidr
  common_tags        = local.common_tags

  eks_version    = var.eks_version
  capacity_type  = var.capacity_type
  instance_types = var.instance_types
  desired_size   = var.eks_desired_size
  max_size       = var.eks_max_size
  min_size       = var.eks_min_size
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