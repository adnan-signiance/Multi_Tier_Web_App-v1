variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance per region"
  type        = map(string)
  default = {
    us-east-1 = "ami-05e9f935686cfe637"
  }
}