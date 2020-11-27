provider "aws" {
  region = "us-west-2"
}

// comment this out to create S3 bucket / dynnamodb table
// then uncomment and run `terraform init` and `terraform apply`
// to move state to S3 backend
terraform {
  backend "s3" {
    bucket = "energon-software-test-state"
    key    = "global/s3/terraform.tfstate"
    region = "us-west-2"

    dynamodb_table = "energon-software-test-state-locks"
    encrypt        = true
  }
}

/* Terraform backend */

resource "aws_s3_bucket" "terraform_state" {
  bucket = "energon-software-test-state"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "energon-software-test-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

/* Outputs */

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
