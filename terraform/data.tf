data "aws_secretsmanager_secret_version" "slack" {
  secret_id = "slack-dev"
}
