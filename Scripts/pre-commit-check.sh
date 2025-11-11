#!/bin/bash

# Pre-commit hook for Terraform validation
set -e

echo "Running Terraform format check..."
terraform fmt -check -recursive

echo "Running Terraform validation..."
terraform validate

echo "Running Terraform security check with tfsec..."
tfsec .

echo "All checks passed!"