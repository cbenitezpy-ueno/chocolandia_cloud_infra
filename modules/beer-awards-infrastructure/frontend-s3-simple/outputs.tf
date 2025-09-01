# Outputs for S3 Static Website Module

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "website_endpoint" {
  description = "S3 website endpoint URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "website_domain" {
  description = "S3 website domain"
  value       = aws_s3_bucket_website_configuration.frontend.website_domain
}

output "website_url" {
  description = "Complete website URL"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "bucket_domain_name" {
  description = "Bucket domain name for ALB origin"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

output "hosted_zone_id" {
  description = "S3 website hosted zone ID"
  value       = aws_s3_bucket.frontend.hosted_zone_id
}