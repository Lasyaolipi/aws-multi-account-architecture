variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "eks_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "capacity_type" {
  description = "Type of capacity for node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "instance_types" {
  description = "List of instance types for node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of nodes in node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in node group"
  type        = number
  default     = 5
}

variable "min_size" {
  description = "Minimum number of nodes in node group"
  type        = number
  default     = 1
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}