output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb-adnan.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.alb-adnan.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB for CloudWatch metrics"
  value       = aws_lb.alb-adnan.arn_suffix
}

output "target_group_arn" {
  description = "The full ARN of the blue target group (used by ECS service; CodeDeploy manages green)"
  value       = aws_lb_target_group.blue-tg-adnan.arn
}

output "target_group_arn_suffix" {
  description = "The ARN suffix of the blue target group for CloudWatch metrics"
  value       = aws_lb_target_group.blue-tg-adnan.arn_suffix
}

output "alb_listener_arn" {
  description = "The ARN of the HTTP listener — used by CodeDeploy blue-green deployment group"
  value       = aws_lb_listener.alb-listener-adnan.arn
}

output "blue_target_group_name" {
  description = "Name of the blue target group — used by CodeDeploy blue-green config"
  value       = aws_lb_target_group.blue-tg-adnan.name
}

output "green_target_group_name" {
  description = "Name of the green target group — used by CodeDeploy blue-green config"
  value       = aws_lb_target_group.green-tg-adnan.name
}

