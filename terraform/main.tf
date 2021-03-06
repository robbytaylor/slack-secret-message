module "apigateway" {
  source = "github.com/robbytaylor/terraform-apigateway-lambda?ref=v1.1.0"

  api_name             = var.api_name
  lambda_function_name = var.lambda_function_name
  domain_name          = var.domain_name
  route53_hosted_zone  = var.route53_hosted_zone
  http_methods         = ["GET", "POST"]

  providers = {
    aws     = "aws"
    aws.acm = "aws.acm"
  }

  environment_variables = {
    "COMMAND" : var.command
    "SLACK_SIGNING_SECRET" : local.slack_signing_secret
    "SLACK_CLIENT_ID" : local.slack_client_id
    "SLACK_CLIENT_SECRET" : local.slack_client_secret
    "SLACK_SCOPES" : "bot,commands,users:read.email,users.profile:read,users:read,chat:write:bot"
    "TABLE_NAME" : aws_dynamodb_table.teams.name
  }

  tags = var.tags
}

module circleci {
  source       = "robbytaylor/deploy-user/aws"
  version      = "0.1.0"
  tags         = var.tags
  username     = var.circleci_user
  lambda_arn   = module.apigateway.lambda_arn
}