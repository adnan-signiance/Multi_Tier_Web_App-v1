# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# ALB Outputs
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

# CloudFront Outputs
output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution — use this to access your application"
  value       = module.cloudfront.cloudfront_domain_name
}

# SNS Outputs
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications"
  value       = module.sns.sns_topic_arn
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "backend_ecr_repository_url" {
  description = "ECR repository URL for the backend — push your Docker image here before applying"
  value       = module.ecs.backend_ecr_repository_url
}

output "frontend_ecr_repository_url" {
  description = "ECR repository URL for the frontend"
  value       = module.ecs.frontend_ecr_repository_url
}

# RDS Outputs
output "rds_endpoint" {
  description = "The RDS connection endpoint"
  value       = module.rds.db_endpoint
}

# Secrets Manager
output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  value       = module.secretsmanager.secret_arn
}
