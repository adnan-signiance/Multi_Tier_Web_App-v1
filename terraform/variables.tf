variable "region" {
  default = "us-east-1"
}

variable "amiId" {
  type = map(any)
  default = {
    us-east-1 = "ami-0030e4319cbf4dbf2"
    us-east-2 = "ami-0503ed50b531cc445"
  }
}