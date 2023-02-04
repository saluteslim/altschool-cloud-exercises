# Create hosted zone - Route53
resource "aws_route53_zone" "host-zone" {
  name = var.domain_names.domain_name
#   tags = {
#     Environment = "prod"
#   }
}

#Create terraform sub-domain 'A' record

resource "aws_route53_record" "tes_domain" {
  zone_id = aws_route53_zone.host-zone.id
  name    = var.domain_names.subdomain_name
  type    = "A"
  alias {
    name                   = aws_lb.tes-lb.dns_name
    zone_id                = aws_lb.tes-lb.zone_id
    evaluate_target_health = true
  }
}