resource "aws_acm_certificate" "cert" {
  domain_name       = "hswg94.com"
  subject_alternative_names = ["*.hswg94.com"]
  validation_method = "DNS"
}