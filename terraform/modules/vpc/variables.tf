variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "11.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "11.0.1.0/26"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "11.0.2.0/26"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "11.0.3.0/26"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "11.0.4.0/26"
}

variable "availability_zone_1" {
  description = "First availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Second availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "multi-tier-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
