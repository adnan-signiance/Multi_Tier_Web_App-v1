output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb-adnan.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.alb-adnan.arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB for CloudWatch"
  value       = aws_lb.alb-adnan.arn_suffix
}

output "target_group_arn_suffix" {
  description = "The ARN suffix of the target group for CloudWatch"
  value       = aws_lb_target_group.tg-adnan.arn_suffix
}
