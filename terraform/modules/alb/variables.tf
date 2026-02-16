variable "vpc_id" {
  description = "The VPC ID where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "The security group ID for the ALB"
  type        = string
}

variable "ec2_instance_id" {
  description = "The EC2 instance ID to attach to the target group"
  type        = string
}
