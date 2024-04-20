
# create a record set in route 53
resource "aws_route53_record" "alb" {
  zone_id = var.zone_id
  name    = var.alb_domain
  ttl = 300
  records = [aws_lb.application_load_balancer.dns_name]
  type    = "CNAME"
}

resource "aws_acm_certificate" "alb" {
  domain_name       = var.alb_domain
  validation_method = "DNS"

  tags = { Name = "${var.name}-main" }
}

resource "aws_route53_record" "linux-alb-certificate-validation-record" {
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
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "linux-certificate-validation" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.linux-alb-certificate-validation-record : record.fqdn]
}


