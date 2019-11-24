resource "aws_dynamodb_table" "teams" {
  name           = "teams"
  hash_key       = "team_id"
  read_capacity  = var.dynamodb_read_capabity
  write_capacity = var.dynamodb_write_capabity
  billing_mode   = var.dynamodb_billing_mode

  attribute {
    name = "team_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}

data aws_iam_policy_document dynamodb {
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem"
    ]

    resources = [aws_dynamodb_table.teams.arn]
  }
}

resource aws_iam_policy dynamodb {
  name   = "AccessTeamsDynamoDBTable"
  policy = data.aws_iam_policy_document.dynamodb.json
}

resource aws_iam_role_policy_attachment dynamodb {
  role       = module.apigateway.lambda_role_name
  policy_arn = aws_iam_policy.dynamodb.arn
}
