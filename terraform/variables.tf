variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "dev, staging, or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Prefix for all resource names"
  type        = string
  default     = "verichain"
}

variable "lambda_memory_mb" {
  description = "RAM for Lambda in megabytes"
  type        = number
  default     = 512
}

variable "lambda_timeout_seconds" {
  description = "Max seconds Lambda can run before being killed"
  type        = number
  default     = 30
}

variable "lab_role_arn" {
  description = "Pre-existing LabRole ARN from AWS Academy student account"
  type        = string
  # You set this in terraform.tfvars (gitignored)
  # Example: "arn:aws:iam::123456789012:role/LabRole"
}
