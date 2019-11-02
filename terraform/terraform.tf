terraform {
  required_version = "~> 0.12"

  backend "s3" {
    bucket         = "terraform.slack-secret-message.robbytaylor.io"
    key            = "terraform.tfstate"
    dynamodb_table = "slack-secret-message-terraform-state-lock"
    region         = "eu-west-2"
  }
}