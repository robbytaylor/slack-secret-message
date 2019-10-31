resource "aws_iam_role" "slack-sharelock" {
  name = "SlackSharelock"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      aws_cloudwatch_log_group.logs.arn
    ]
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "SlackSharelockLambdaLogging"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.slack-sharelock.name
  policy_arn = aws_iam_policy.lambda.arn
}
