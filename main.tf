provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = var.github_token
}

data "aws_region" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

resource "aws_apigatewayv2_api" "github_webhook_api" {
  name          = "github-webhook-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id = aws_apigatewayv2_api.github_webhook_api.id
  name          = "prod"
  auto_deploy   = true
}

resource "aws_apigatewayv2_integration" "github_webhook_integration" {
  api_id = aws_apigatewayv2_api.github_webhook_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  integration_uri = aws_lambda_function.github_webhook_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "github_webhook_route" {
    api_id = aws_apigatewayv2_api.github_webhook_api.id
    route_key = "POST /"
    target = "integrations/${aws_apigatewayv2_integration.github_webhook_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id = "AllowExecutionFromAPIGateway"
  action       = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook_lambda.function_name
  principal    = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${var.aws_account_id}:${aws_apigatewayv2_api.github_webhook_api.id}/*/*/*"
}

output "api_gateway_url" {
  value = "${aws_apigatewayv2_api.github_webhook_api.api_endpoint}/prod/"
}

resource "github_repository_webhook" "github_webhook" {
  repository = "checkpoint-project"
  events     = ["pull_request"]

  configuration {
    url          = "${aws_apigatewayv2_api.github_webhook_api.api_endpoint}/prod/"
    content_type = "json"
    insecure_ssl = true
    secret       = var.github_webhook_secret
  }
}

resource "aws_lambda_function" "github_webhook_lambda" {
  function_name = "github-webhook-lambda"
  handler      = "app.lambda_handler"
  runtime      = "python3.9"

  filename = "./files-changed-log-lambda.zip"

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      GITHUB_WEBHOOK_SECRET = var.github_webhook_secret
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/github-webhook-lambda"
}

resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowExecutionToCloudWatchLogs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook_lambda.function_name
  principal     = "logs.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group.arn
}
