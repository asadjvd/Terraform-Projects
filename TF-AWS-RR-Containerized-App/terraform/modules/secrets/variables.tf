variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database endpoint hostname"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "recipedb"
}

variable "recovery_window_in_days" {
  description = "Number of days to retain secret after deletion (0 for immediate deletion, 7-30 for recovery window)"
  type        = number
  default     = 0 # Immediate deletion for dev/test. Use 7+ for production
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}