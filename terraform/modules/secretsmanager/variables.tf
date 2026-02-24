variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
  default     = "rds/mysql/credentials"
}

variable "db_username" {
  description = "Database master username to store in the secret"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password to store in the secret — use a strong password"
  type        = string
  sensitive   = true
}
