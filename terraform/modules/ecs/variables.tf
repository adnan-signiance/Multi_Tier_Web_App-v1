variable "private_subnets" {
  description = "List of private subnet IDs for ECS EC2 instances"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS EC2 instances"
  type        = string
}

variable "ecs_instance_profile_arn" {
  description = "ARN of the IAM instance profile for ECS EC2 instances"
  type        = string
}

variable "db_host" {
  description = "RDS hostname — replaces the 'db' Docker Compose service"
  type        = string
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "my_app_db"
}

variable "db_username" {
  description = "MySQL username"
  type        = string
}

variable "db_password" {
  description = "MySQL password"
  type        = string
  sensitive   = true
}

variable "target_group_arn" {
  description = "ARN of the ALB target group (port 80 — points at nginx/client container)"
  type        = string
}

variable "aws_region" {
  description = "AWS region (used for CloudWatch log configuration)"
  type        = string
  default     = "us-east-1"
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the Secrets Manager secret for DB credentials"
  type        = string
}
