variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}