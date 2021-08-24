provider "aws" {
  region     = var.region
}

resource "aws_s3_bucket" "terraform_state_s3" {
  #make sure you give unique bucket name
  bucket = "terraform-bucket-lock" 
  force_destroy = true

  # Enable versioning to see full revision history of our state files
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
# Give unique name for dynamo table name
  name         = "tf-up-and-run-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
