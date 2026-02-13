terraform {
  backend "s3" {
    bucket = "bkt-terraform-adnan"
    key    = "terraform_state/backend"
    region = "us-east-1"
  }
}