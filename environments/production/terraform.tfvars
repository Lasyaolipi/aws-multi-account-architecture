aws_region     = "ap-south-1"
aws_account_id = "391313099163"
environment    = "production"
project_name   = "multi-account-arch"
vpc_cidr       = "10.0.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

# Disable GuardDuty and Security Hub initially due to subscription requirements
enable_guardduty   = false
enable_security_hub = false

github_owner = "your-username"
github_repo  = "aws-multi-account-architecture"

# EKS Configuration
eks_version    = "1.28"
capacity_type  = "ON_DEMAND"
instance_types = ["t3.medium"]
eks_desired_size = 2
eks_max_size   = 5
eks_min_size   = 1