resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-api-${var.environment}"
  retention_in_days = 30
}

data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "/tmp/verichain_placeholder.zip"
  source {
    content  = "exports.handler = async () => ({ statusCode: 200, body: JSON.stringify({ status: 'placeholder' }) });"
    filename = "index.js"
  }
}

resource "aws_lambda_function" "api" {
  function_name    = "${var.project_name}-api-${var.environment}"
  role             = var.lab_role_arn
  runtime          = "nodejs20.x"
  handler          = "dist/lambda.handler"
  memory_size      = var.lambda_memory_mb
  timeout          = var.lambda_timeout_seconds
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT            = var.environment
      NODE_ENV               = var.environment == "prod" ? "production" : "development"
      USERS_TABLE            = aws_dynamodb_table.users.name
      DOCUMENTS_TABLE        = aws_dynamodb_table.documents.name
      VERIFICATION_LOG_TABLE = aws_dynamodb_table.verification_log.name
      S3_BUCKET              = aws_s3_bucket.documents.bucket
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format          = "$context.requestId $context.httpMethod $context.routeKey $context.status"
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "catch_all" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
