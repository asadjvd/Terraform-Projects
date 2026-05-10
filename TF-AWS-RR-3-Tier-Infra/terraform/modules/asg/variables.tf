variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID (leave empty for latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for webapp instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ASG"
  type        = map(string)
}

variable "target_group_arn" {
  description = "Target group ARN for ALB"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "bucket_name" {
  type = string
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}