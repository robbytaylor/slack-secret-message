data "archive_file" "slack-sharelock" {
  type        = "zip"
  source_dir  = "${path.root}/../app"
  output_path = "${path.root}/../dist/lambda.zip"
}


resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.slack-sharelock.output_path
  function_name = "slack-sharelock"
  role          = aws_iam_role.slack-sharelock.arn
  handler       = "handler.app"
  runtime       = "nodejs10.x"

  source_code_hash = data.archive_file.slack-sharelock.output_base64sha256

  environment {
    variables = {
      "SLACK_SIGNING_SECRET" : local.slack_signing_secret
      "SLACK_BOT_TOKEN" : local.slack_bot_token
    }
  }
}
