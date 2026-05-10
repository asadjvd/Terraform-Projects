variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "secrets_arns" {
  description = "Map of Secrets Manager ARNs that EC2 instances can access"
  type = list(string)
  default = ["*"]
}

variable "s3_bucket_arn" {
  type = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}