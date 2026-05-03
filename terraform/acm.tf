provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "website" {
  provider = aws.us-east-1

  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name    = "${var.project_name}-cert"
    Project = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# add verification records to Route53
resource "aws_route53_record" "verification" {
  for_each = {
    for dvo in aws_acm_certificate.website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# waitting for certificate validation
resource "aws_acm_certificate_validation" "website" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.website.arn
  validation_record_fqdns = [for record in aws_route53_record.verification : record.fqdn]
}