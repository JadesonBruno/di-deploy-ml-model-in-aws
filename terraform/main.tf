terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket = "di-terraform-state-767397903600"
    key = "deploy-ml-model-dev/terraform.tfstate"
    region = "us-east-2"
    encrypt  = true
  }
}


provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source = "./modules/vpc"
  project_name = var.project_name
  environment = var.environment
  vpc_cidr_block = var.vpc_cidr_block
}


module "ml_api_bucket" {
  source = "./modules/ml_api_bucket"
  project_name = var.project_name
  environment = var.environment
}


module "api" {
  source = "./modules/api"
  project_name = var.project_name
  environment = var.environment
  instance_type = var.instance_type
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  allow_ips = var.allow_ips
  ml_api_bucket_arn = module.ml_api_bucket.ml_api_bucket_arn
  ml_api_bucket_name = module.ml_api_bucket.ml_api_bucket_name
}
