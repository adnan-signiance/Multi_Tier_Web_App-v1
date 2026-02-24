variable "secret_arn" {
  description = "ARN of the Secrets Manager secret for DB credentials"
  type        = string
}

variable "s3_artifacts_arn" {
  description = "ARN of the S3 bucket used by CodePipeline for artifacts"
  type        = string
}

