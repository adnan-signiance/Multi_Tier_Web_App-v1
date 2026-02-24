variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  type        = string
}

variable "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy role"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline role"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "frontend_ecr_url" {
  description = "Frontend ECR repository URL"
  type        = string
}

variable "backend_ecr_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for CodePipeline artifacts"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue target group"
  type        = string
}

variable "green_target_group_name" {
  description = "Name of the green target group"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role — injected into taskdef.json at build time"
  type        = string
}
