resource "aws_security_group" "ml_api" {
  name = "${var.project_name}-${var.environment}-ml-api-sg"
  description = "Security group for ML API EC2 instance"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH access"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.allow_ips
  }

  ingress {
    description = "Allow HTTP access to ML API"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allow_ips
  }

  ingress {
    description = "Allow ICMP ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.allow_ips
  }


  ingress {
    description = "Allow Connections to ML API"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.allow_ips
  }

  ingress {
    description = "Allow Instance Connect"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    prefix_list_ids = ["pl-03915406641cb1f53"]
  }

  ingress {
    description = "Allow all traffic from same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ml-api-sg"
    Project = var.project_name
    Environment = var.environment
    Service = "ml-api"
    Terraform = "true"
  }
}
