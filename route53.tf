//Create a hosted zone
resource "aws_route53_zone" "primary" {
  name = "hswg94.com"
}

//Create Records
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "api.ecomm.hswg94.com"
  type    = "A"

  alias {
    name                   = aws_lb.ecomm-api-alb.dns_name
    zone_id                = aws_lb.ecomm-api-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53domains_registered_domain" "update_domain_ns" {
  domain_name = "hswg94.com"
  auto_renew  = "false"
  transfer_lock = "false"
  dynamic "name_server" {
    for_each = toset(aws_route53_zone.primary.name_servers)
    content {
      name = name_server.value
    }
  }
  # The example result after iteration will be this
  # name_server {
  #   name = aws_route53_zone.primary.name_servers[0]
  # }
  # name_server {
  #   name = aws_route53_zone.primary.name_servers[1]
  # }
  # name_server {
  #   name = aws_route53_zone.primary.name_servers[2]
  # }
  # name_server {
  #   name = aws_route53_zone.primary.name_servers[3]
  # }
}