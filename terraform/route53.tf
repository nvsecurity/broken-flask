
resource "aws_route53_record" "flask" {
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = aws_alb.this.dns_name
    zone_id                = aws_alb.this.zone_id
    evaluate_target_health = true
  }
}
