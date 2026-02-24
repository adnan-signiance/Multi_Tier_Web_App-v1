output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db.arn
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value = var.db_password
}
