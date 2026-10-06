//Create a hosted zone
resource "aws_route53_zone" "this" {
  name = var.domain_name
}

# Update name servers on the registered domain to match hosted zone
resource "aws_route53domains_registered_domain" "this" {
  domain_name   = aws_route53_zone.this.name
  auto_renew    = "false"
  transfer_lock = "false"

  dynamic "name_server" {
    for_each = toset(aws_route53_zone.this.name_servers)
    content {
      name = name_server.value
    }
  }
}

/////////////

// Certificate for the ALB in AP-SOUTHEAST-1
resource "aws_acm_certificate" "alb" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}",
    "*.${var.api_domain}",
  ]
  validation_method = "DNS"

  # The ALB listener uses this certificate, so a replacement must exist before the old one is deleted
  lifecycle {
    create_before_destroy = true
  }
}

// Create Record for Validating Certificate in AP-SOUTHEAST-1
resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}

/////////////

// Certificate for CloudFront, which only accepts certificates from US-EAST-1
resource "aws_acm_certificate" "cloudfront" {
  region      = "us-east-1"
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}",
    "*.${var.frontend_domain}",
  ]
  validation_method = "DNS"

  # The CloudFront distribution uses this certificate, so a replacement must exist before the old one is deleted
  lifecycle {
    create_before_destroy = true
  }
}

// Create Record for Validating Certificate in US-EAST-1
resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "cloudfront" {
  region                  = "us-east-1"
  certificate_arn         = aws_acm_certificate.cloudfront.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_validation : record.fqdn]
}
