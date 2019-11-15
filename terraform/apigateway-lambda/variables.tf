locals {
  account_id = data.aws_caller_identity.current.account_id
}

variable api_name {
  type = string
}

variable environment_variables {
  type    = map
  default = {}
}

variable http_method {
  type    = string
  default = "GET"
}

variable lambda_function_name {
  type = string
}

variable lambda_handler {
  type    = string
  default = "handler.app"
}

variable lambda_runtime {
  type    = string
  default = "nodejs10.x"
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

variable stage {
  type    = string
  default = "prod"
}
