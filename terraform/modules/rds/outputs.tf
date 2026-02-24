output "db_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.rds-adnan.endpoint
}

output "db_address" {
  description = "The hostname of the RDS instance (without port)"
  value       = aws_db_instance.rds-adnan.address
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.rds-adnan.db_name
}

output "db_port" {
  description = "The port the RDS instance listens on"
  value       = aws_db_instance.rds-adnan.port
}
