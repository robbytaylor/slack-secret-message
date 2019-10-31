data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "slack" {
  secret_id = "slack-sharelock"
}
