#!/bin/bash

# Script to setup Terraform backend
set -e

ACCOUNT_ID="391313099163"
REGION="ap-south-1"
ENVIRONMENT="production"
PROJECT_NAME="multi-account-arch"

BUCKET_NAME="${ENVIRONMENT}-${PROJECT_NAME}-terraform-state-${REGION}"
TABLE_NAME="${ENVIRONMENT}-${PROJECT_NAME}-terraform-locks"

echo "Setting up Terraform backend resources..."

# Create S3 bucket for Terraform state
echo "Creating S3 bucket: $BUCKET_NAME"
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Enable versioning on the bucket
echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable encryption on the bucket
echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
echo "Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
echo "Creating DynamoDB table: $TABLE_NAME"
aws dynamodb create-table \
    --table-name $TABLE_NAME \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION

# Wait for DynamoDB table to be active
echo "Waiting for DynamoDB table to be active..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

echo "Backend setup completed!"
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $TABLE_NAME"
echo ""
echo "You can now run: terraform init"