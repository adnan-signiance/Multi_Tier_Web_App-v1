output "ecs_instance_profile_arn" {
  description = "ARN of the ECS EC2 instance profile"
  value       = aws_iam_instance_profile.ecs_adnan.arn
}

output "ecs_instance_profile_name" {
  description = "Name of the ECS EC2 instance profile"
  value       = aws_iam_instance_profile.ecs_adnan.name
}

output "ecs_instance_role_arn" {
  description = "ARN of the ECS EC2 IAM role"
  value       = aws_iam_role.ecs_instance_role_adnan.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  value       = aws_iam_role.ecs_task_execution_role_adnan.arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy role"
  value       = aws_iam_role.codedeploy_role.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}
