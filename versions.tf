terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "production-multi-account-arch-terraform-state-ap-south-1"
    key            = "production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "production-multi-account-arch-terraform-locks"
    encrypt        = true
  }
}