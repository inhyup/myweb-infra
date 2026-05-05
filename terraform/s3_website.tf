resource "aws_s3_bucket" "website" {
  #checkov:skip=CKV_AWS_18: Access logging to cf_logs bucket configured via CloudFront
  #checkov:skip=CKV_AWS_145: KMS encryption not required for public static site
  #checkov:skip=CKV_AWS_144: Cross-region replication not required for personal site
  #checkov:skip=CKV2_AWS_62: Event notifications not required for personal site
  #checkov:skip=CKV2_AWS_61: Lifecycle configuration not required for personal site
  bucket = var.domain_name

  tags = {
    Name    = "${var.project_name}-website"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.website.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}

