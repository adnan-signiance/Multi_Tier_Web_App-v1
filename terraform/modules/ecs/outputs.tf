output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs-cluster-adnan.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.ecs-cluster-adnan.name
}

output "backend_ecr_repository_url" {
  description = "ECR URL for the server (backend) image — push your Node/Express image here"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_url" {
  description = "ECR URL for the client (frontend) image — push your Nginx/React image here"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecs_service_name" {
  description = "Name of the ECS app service"
  value       = aws_ecs_service.app.name
}
