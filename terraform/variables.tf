variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance per region"
  type        = map(string)
  default = {
    us-east-1 = "ami-0030e4319cbf4dbf2"
    us-east-2 = "ami-0503ed50b531cc445"
  }
}