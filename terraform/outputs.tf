# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.instance_id
}

# EC2 Private IP
output "ec2_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = module.ec2.instance_private_ip
}

# ALB Outputs
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

# CloudFront Outputs
output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution - Use this to access your application"
  value       = module.cloudfront.cloudfront_domain_name
}

# SNS Outputs
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for notifications"
  value       = module.sns.sns_topic_arn
}
