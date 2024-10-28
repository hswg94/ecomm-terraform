//Create a hosted zone
resource "aws_route53_zone" "primary" {
  name = "hswg94.com"
}

# Update name servers on the registered domain to match hosted zone
resource "aws_route53domains_registered_domain" "update-domain-ns" {
  domain_name   = "hswg94.com"
  auto_renew    = "false"
  transfer_lock = "false"

  dynamic "name_server" {
    for_each = toset(aws_route53_zone.primary.name_servers)
    content {
      name = name_server.value
    }
  }
}

//Create Records
resource "aws_route53_record" "api-backend-endpoint" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "api.hswg94.com"
  type    = "A"

  alias {
    name                   = aws_lb.ecomm-api-alb.dns_name
    zone_id                = aws_lb.ecomm-api-alb.zone_id
    evaluate_target_health = true
  }
}

//Create Records
resource "aws_route53_record" "api-frontend-endpoint" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "ecomm.hswg94.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3-distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3-distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.ap-southeast-1-cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.primary.zone_id
}
