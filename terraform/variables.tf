locals {
  account_id           = data.aws_caller_identity.current.account_id
  slack_credentials    = jsondecode(data.aws_secretsmanager_secret_version.slack.secret_string)
  slack_bot_token      = local.slack_credentials["SLACK_BOT_TOKEN"]
  slack_signing_secret = local.slack_credentials["SLACK_SIGNING_SECRET"]
  slack_oauth_token    = local.slack_credentials["SLACK_OAUTH_TOKEN"]
}

variable api_name {
  type = string
}

variable lambda_function_name {
  type    = string
}

variable route53_hosted_zone {
  type    = string
  default = ""
}

variable domain_name {
  type    = string
  default = ""
}

variable region {
  type    = string
  default = "eu-west-2"
}
