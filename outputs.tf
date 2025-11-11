output "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_lock_table" {
  description = "DynamoDB table for Terraform locks"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}