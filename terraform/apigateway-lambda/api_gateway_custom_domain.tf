data "aws_route53_zone" "zone" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.route53_hosted_zone
}

resource "aws_api_gateway_domain_name" "api" {
  count           = var.domain_name != "" ? 1 : 0
  certificate_arn = aws_acm_certificate_validation.cert[0].certificate_arn
  domain_name     = var.domain_name
}

resource "aws_route53_record" "api" {
  count   = var.domain_name != "" ? 1 : 0
  name    = aws_api_gateway_domain_name.api[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.zone[0].zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api[0].cloudfront_zone_id
  }
}

resource "aws_acm_certificate" "cert" {
  count             = var.domain_name != "" ? 1 : 0
  provider          = aws.acm
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  count   = var.domain_name != "" ? 1 : 0
  name    = aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.zone[0].zone_id
  records = [aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = var.domain_name != "" ? 1 : 0
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[0].fqdn]
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  count       = var.domain_name != "" ? 1 : 0
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.api[0].domain_name
}
