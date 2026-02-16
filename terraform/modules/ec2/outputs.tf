output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2-adnan.id
}

output "instance_private_ip" {
  description = "The private IP of the EC2 instance"
  value       = aws_instance.ec2-adnan.private_ip
}
