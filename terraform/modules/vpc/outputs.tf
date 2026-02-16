output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc-adnan.id
}

output "public_subnet_1_id" {
  description = "The ID of public subnet 1"
  value       = aws_subnet.publicsubnet1-adnan.id
}

output "public_subnet_2_id" {
  description = "The ID of public subnet 2"
  value       = aws_subnet.publicsubnet2-adnan.id
}

output "private_subnet_id" {
  description = "The ID of private subnet"
  value       = aws_subnet.privatesubnet-adnan.id
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb-sg-adnan.id
}

output "ec2_security_group_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2-sg-adnan.id
}
