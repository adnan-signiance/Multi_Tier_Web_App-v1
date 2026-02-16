variable "subnet_id" {
  description = "The subnet ID where EC2 instance will be launched"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Name for the SSH key pair"
  type        = string
  default     = "kpadnan"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJS9xxe3zsDMnKsB+ae/Bcn+cCSnhw9kjqdXAP1Xz2ZW asus@Adnan"
}
