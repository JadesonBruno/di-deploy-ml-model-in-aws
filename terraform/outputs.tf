output "ml_api_bucket_name" {
  description = "Nome do bucket S3 para o modelo ML"
  value       = module.ml_api_bucket.bucket_name
}

output "ml_api_instance_public_ip" {
  description = "IP público da instância EC2 da API ML"
  value       = module.api.instance_public_ip
}
