resource "aws_iam_role" "ml_api" {
  name = "${var.project_name}-${var.environment}-ml-api-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ml-api-role"
    Project = var.project_name
    Environment = var.environment
    Service = "ml-api"
    Terraform = "true"
  }
}


resource "aws_iam_policy" "ml_api" {
  name = "${var.project_name}-${var.environment}-ml-api-policy"
  description = "IAM policy for ML API"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
            "${var.ml_api_bucket_arn}",
            "${var.ml_api_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = {
    Name  = "${var.project_name}-${var.environment}-ml-api-policy"
    Project = var.project_name
    Environment = var.environment
    Service = "ml-api"
    Terraform = "true"
  }
}


resource "aws_iam_role_policy_attachment" "ml_api" {
  role = aws_iam_role.ml_api.name
  policy_arn = aws_iam_policy.ml_api.arn
}
