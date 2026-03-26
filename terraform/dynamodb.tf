# Table 1: Users
resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-users-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name            = "email-index"
    hash_key        = "email"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}

# Table 2: Documents
resource "aws_dynamodb_table" "documents" {
  name         = "${var.project_name}-documents-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "documentId"
  range_key    = "userId"

  attribute {
    name = "documentId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "userId-index"
    hash_key        = "userId"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "status-index"
    hash_key        = "status"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
}

# Table 3: Verification Log
resource "aws_dynamodb_table" "verification_log" {
  name         = "${var.project_name}-verification-log-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "verificationId"

  attribute {
    name = "verificationId"
    type = "S"
  }

  attribute {
    name = "documentId"
    type = "S"
  }

  global_secondary_index {
    name            = "documentId-index"
    hash_key        = "documentId"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
}
