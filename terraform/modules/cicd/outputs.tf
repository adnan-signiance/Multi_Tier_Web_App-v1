output "codebuild_project_arn" {
  description = "ARN of the CodeBuild project (passed to IAM for CodePipeline policy)"
  value       = aws_codebuild_project.ecs-bluegreen.arn
}

output "codestar_connection_arn" {
  description = "ARN of the CodeStar Connections GitHub connection (passed to IAM for CodePipeline policy)"
  value       = aws_codestarconnections_connection.github.arn
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.ecs-bluegreen.name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.ecs-bluegreen.deployment_group_name
}
