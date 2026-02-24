output "bucket_name" {
  description = "Name of the S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket used for CodePipeline artifacts"
  value       = aws_s3_bucket.codepipeline_bucket.arn
}
