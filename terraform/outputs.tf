output "api_gateway_url" {
  description = "Public URL for your API - put this in frontend .env"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/api"
}

output "s3_documents_bucket" {
  description = "S3 bucket name for uploaded documents"
  value       = aws_s3_bucket.documents.bucket
}

output "s3_lambda_code_bucket" {
  description = "S3 bucket for Lambda deployment zips"
  value       = aws_s3_bucket.lambda_code.bucket
}

output "dynamodb_users_table" {
  description = "DynamoDB users table name"
  value       = aws_dynamodb_table.users.name
}

output "dynamodb_documents_table" {
  description = "DynamoDB documents table name"
  value       = aws_dynamodb_table.documents.name
}

output "dynamodb_verification_log_table" {
  description = "DynamoDB verification log table name"
  value       = aws_dynamodb_table.verification_log.name
}

output "lambda_function_name" {
  description = "Lambda function name - used by GitHub Actions to deploy code"
  value       = aws_lambda_function.api.function_name
}
