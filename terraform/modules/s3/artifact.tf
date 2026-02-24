resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "ecs-bluegreen-artifacts-${var.environment}"

  force_destroy = true
}