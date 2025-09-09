# Key Pair para SSH (gera chave automaticamente)
resource "tls_private_key" "ml_api" {
    algorithm = "RSA"
    rsa_bits = 4096
}


resource "aws_key_pair" "ml_api" {
    key_name   = "${var.project_name}-${var.environment}-ml-api-key"
    public_key = tls_private_key.ml_api.public_key_openssh

    tags = {
        Name = "${var.project_name}-${var.environment}-ml-api-key"
        Project = var.project_name
        Environment = var.environment
        Service = "ml-api"
        Terraform = "true"
  }
}


# Save private key locally
resource "local_file" "private_key" {
  content = tls_private_key.ml_api.private_key_pem
  filename = "${path.root}/keys/${var.project_name}-${var.environment}-ml-api-key.pem"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/keys/${var.project_name}-${var.environment}-ml-api-key.pem"
  }
}


resource "aws_instance" "ml_api" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.ml_api.key_name
    subnet_id = var.public_subnet_ids[0]
    vpc_security_group_ids = [aws_security_group.ml_api.id]
    iam_instance_profile = aws_iam_instance_profile.ml_api.name

    user_data = templatefile(
        "${path.module}/user_data.sh", {
            ml_api_bucket_name = var.ml_api_bucket_name
        }
    )

    tags = {
        Name = "${var.project_name}-${var.environment}-ml-api"
        Project = var.project_name
        Environment = var.environment
        Service = "ml-api"
        Terraform = "true"
  }
}
