// Certificate for resources in AP-SOUTHEAST-1
resource "aws_acm_certificate" "ap-southeast-1-cert" {
  domain_name       = "hswg94.com"
  subject_alternative_names = ["*.hswg94.com"]
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "ap-southeast-1-cert" {
  certificate_arn         = aws_acm_certificate.ap-southeast-1-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation : record.fqdn]
}

/////////////

// Certificate for CloudFront in US-EAST-1
resource "aws_acm_certificate" "us-east-1-cert" {
  provider = aws.us-east-1
  domain_name       = "hswg94.com"
  subject_alternative_names = ["*.hswg94.com"]
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "us-east-1-cert" {
  provider = aws.us-east-1
  certificate_arn         = aws_acm_certificate.us-east-1-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation : record.fqdn]
}