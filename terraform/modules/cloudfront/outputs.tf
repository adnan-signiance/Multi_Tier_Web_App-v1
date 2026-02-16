output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront-adnan.domain_name
}

output "cloudfront_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.cloudfront-adnan.id
}
