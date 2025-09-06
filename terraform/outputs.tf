output "ml_api_bucket_name" {
  description = "Name of the S3 bucket for the ML model"
  value = module.ml_api_bucket.ml_api_bucket_name
}

output "ml_api_public_dns" {
  description = "Public DNS of the EC2 instance for the ML API"
  value = module.api.ml_api_public_dns
}
