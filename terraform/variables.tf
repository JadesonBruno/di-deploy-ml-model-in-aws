variable "project_name" {
  description = "Project name"
  type = string
  default = "deploy-ml-model"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type = string
  default = "dev"

  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-2"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type = string
  default = "10.2.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type = string
  default = "ami-0329ba0ced0243e2b" # Amazon Linux 2023 kernel-6.12 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "allow_ips" {
  description = "List of IPs allowed to access EC2 instance"
  type = list(string)
}
