# Data source para AMI mais recente do Amazon Linux 2
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


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
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    key_name = aws_key_pair.ml_api.key_name
    subnet_id = var.public_subnet_ids[0]
    vpc_security_group_ids = [aws_security_group.ml_api.id]
    iam_instance_profile = aws_iam_instance_profile.ml_api.name

    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y \
                    python3 \
                    python3-pip \
                    awscli
                sudo pip3 install \
                    fastapi \
                    uvicorn \
                    scikit-learn \
                    python-multipart
                sudo mkdir -p /data-projects/di-deploy-ml-model-in-aws
                sudo aws s3 sync s3://${var.ml_api_bucket_name} /data-projects/di-deploy-ml-model-in-aws --recursive
                cd /data-projects/di-deploy-ml-model-in-aws
                nohup uvicorn api.fastapi:app --host 0.0.0.0 --port 5000 --workers 4 > /data-projects/di-deploy-ml-model-in-aws/uvicorn.log 2>&1 &
                echo "Uvicorn server started"
                EOF

    tags = {
        Name = "${var.project_name}-${var.environment}-ml-api"
        Project = var.project_name
        Environment = var.environment
        Service = "ml-api"
        Terraform = "true"
  }
}
