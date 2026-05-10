variable "bucket_name" {
  description = "Bucket name"
  type = string
}

variable "bucket_suffix" {
  type = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}