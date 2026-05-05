# CloudFront Access Log Bucket
resource "aws_s3_bucket" "cf_logs" {
  bucket = "${var.project_name}-cf-logs-${var.aws_account_id}"

  tags = {
    Name    = "${var.project_name}-cf-logs"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# CloudFront Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "security" {
  name = "${var.project_name}-security-headers"

  security_headers_config {

    # Clickjacking protection
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # XSS protection
    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }

    #MIME sniffing protection
    content_type_options {
      override = true
    }

    # HTTPS enforcement
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    # Referrer policy
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}