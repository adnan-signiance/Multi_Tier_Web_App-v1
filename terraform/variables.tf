variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance per region"
  type        = map(string)
  default = {
    us-east-1 = "ami-01782085b05e1f94a"
  }
}