module "apigateway" {
  source = "github.com/robbytaylor/terraform-apigateway-lambda"

  api_name             = var.api_name
  lambda_function_name = var.lambda_function_name
  domain_name          = var.domain_name
  route53_hosted_zone  = var.route53_hosted_zone
  http_method          = "POST"

  providers = {
    aws     = "aws"
    aws.acm = "aws.acm"
  }

  environment_variables = {
    "SLACK_SIGNING_SECRET" : local.slack_signing_secret
    "SLACK_BOT_TOKEN" : local.slack_bot_token
    "SLACK_OAUTH_TOKEN" : local.slack_oauth_token
  }
}
