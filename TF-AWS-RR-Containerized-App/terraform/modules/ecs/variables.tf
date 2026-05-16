variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "execution_role_arn" {
  type = string
}

variable "secret_arn" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}

variable "webapp_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "frontend_target_group_arn" {
  type = string
}

variable "backend_target_group_arn" {
  type = string
}

variable "frontend_listener_arn" {
  type = string
}

variable "backend_listener_arn" {
  type = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}