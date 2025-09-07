# Get current AWS account ID
data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "api" {
  bucket = "${var.project_name}-${var.environment}-ml-api-bucket-${data.aws_caller_identity.current.account_id}"

  provisioner "local-exec" {
    command = "aws s3 cp /data-projects/di-deploy-ml-model-in-aws/src s3://${aws_s3_bucket.api.bucket} --recursive"
  }

  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ml-api-bucket-${data.aws_caller_identity.current.account_id}"
    Project = var.project_name
    Environment = var.environment
    Service = "ml-api"
    Terraform = "true"
   }
}


resource "aws_s3_bucket_public_access_block" "api" {
  bucket = aws_s3_bucket.api.id
  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "api" {
  bucket = aws_s3_bucket.api.id
  versioning_configuration {
    status = "Enabled"
  }
}
