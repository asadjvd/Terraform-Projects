variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 5000
}

variable "subnet_ids" {
  type = map(string)
}

variable "security_group_id" {
  type = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}