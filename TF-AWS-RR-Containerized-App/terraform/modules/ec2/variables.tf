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

variable "subnet_id" {
  description = "Webapp subnet ID"
  type        = string
}

variable "frontend" {
  description = "NextJS frontend app repo name in ECR"
  type        = string
}

variable "backend" {
  description = "Flask backend app repo name in ECR"
  type        = string
}

variable "frontend_repo_name" {
  type = string
}

variable "backend_repo_name" {
  type = string
}

variable "frontend_url" {
  description = "Github repo URL for NextJS frontend app"
  type        = string
}

variable "backend_url" {
  description = "Github repo URL for Flask backend app"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}