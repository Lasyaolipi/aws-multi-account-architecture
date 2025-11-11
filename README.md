# AWS Multi-Account Architecture Implementation

This Terraform project implements a comprehensive AWS architecture within a single account (391313099163) in ap-south-1 region with GitHub Actions CI/CD.

## Architecture Components

### Security Services
- AWS GuardDuty
- AWS Security Hub
- AWS Config
- CloudTrail (enable manually)

### Networking
- VPC with public and private subnets
- Internet Gateway
- NAT Gateway
- Route Tables

### DevOps
- ECR Repository
- S3 Bucket for Terraform state
- DynamoDB for state locking
- CodeBuild project

### IAM
- Roles for different services
- GitHub Actions IAM user

### Monitoring
- CloudWatch Log Groups
- SNS Topics for alerts
- CloudWatch Alarms

## GitHub Actions Setup

### 1. Repository Secrets
Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID` - IAM user access key
- `AWS_SECRET_ACCESS_KEY` - IAM user secret key

### 2. Workflows
- **terraform-plan.yml**: Runs on PRs to main branch
- **terraform-apply.yml**: Runs on pushes to main branch

## Deployment Instructions

### 1. Initial Setup
```bash
# Clone the repository
git clone <your-repo-url>
cd aws-multi-account-architecture

# Make scripts executable
chmod +x scripts/*.sh

# Setup Terraform backend
./scripts/setup-backend.sh

# Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values