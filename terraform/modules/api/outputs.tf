output "ml_api_public_dns" {
  description = "Public DNS of the ML API instance"
  value = aws_instance.ml_api.public_dns
}
