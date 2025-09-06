output "ml_api_bucket_arn" {
  description = "ARN of the ML API S3 bucket"
  value = aws_s3_bucket.api.arn
}

output "ml_api_bucket_name" {
  description = "Name of the ML API S3 bucket"
  value = aws_s3_bucket.api.bucket
}
