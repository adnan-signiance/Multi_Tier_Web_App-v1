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

output "private_subnet_1_id" {
  description = "The ID of private subnet 1"
  value       = aws_subnet.privatesubnet1-adnan.id
}

output "private_subnet_2_id" {
  description = "The ID of private subnet 2"
  value       = aws_subnet.privatesubnet2-adnan.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.privatesubnet1-adnan.id, aws_subnet.privatesubnet2-adnan.id]
}

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb-sg-adnan.id
}

output "ecs_security_group_id" {
  description = "The ID of the ECS EC2 instances security group"
  value       = aws_security_group.ecs-sg-adnan.id
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds-sg-adnan.id
}

output "db_subnet_group_name" {
  description = "The name of the RDS DB subnet group"
  value       = aws_db_subnet_group.rds-adnan.name
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat-adnan.id
}

output "nat_gateway_public_ip" {
  description = "The public Elastic IP of the NAT Gateway"
  value       = aws_eip.nat-adnan.public_ip
}
