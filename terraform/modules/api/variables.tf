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

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type = list(string)
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

variable "ml_api_bucket_arn" {
  description = "The ARN of the ML API S3 bucket"
  type = string
}

variable "ml_api_bucket_name" {
  description = "The name of the ML API S3 bucket"
  type = string
}
