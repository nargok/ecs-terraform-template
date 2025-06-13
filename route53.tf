locals {
  domains = {
    prod = "hogehoge.com"
    dev  = "dev.hogehgeo.com"
  }
}

data "aws_route53_zone" "this" {
  name = local.domains[var.env]
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "hogehgoe.${data.aws_route53_zone.this.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.web.dns_name]
}

