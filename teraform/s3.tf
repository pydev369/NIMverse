# S3 Bucket for model storage and shared data
resource "aws_s3_bucket" "nvidia_models" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "NVIDIA Models Storage"
    Project     = var.project_name
    Purpose     = "model-storage"
    Owner       = var.github_username
  }
}

resource "aws_s3_bucket_versioning" "nvidia_models" {
  bucket = aws_s3_bucket.nvidia_models.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "nvidia_models" {
  bucket = aws_s3_bucket.nvidia_models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "nvidia_models" {
  bucket = aws_s3_bucket.nvidia_models.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Policy for S3 access from EKS
resource "aws_iam_policy" "s3_model_access" {
  name        = "${var.project_name}-s3-model-access"
  description = "Policy for accessing model files in S3 from EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.nvidia_models.arn,
          "${aws_s3_bucket.nvidia_models.arn}/*"
        ]
      }
    ]
  })
}