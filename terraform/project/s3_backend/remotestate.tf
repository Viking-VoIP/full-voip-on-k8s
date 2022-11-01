provider "aws" {
  region  = "${var.aws_region}"
}

resource "random_id" "tc-rmstate" {
  byte_length = 4
}

resource "aws_s3_bucket" "tfrmstate" {
  bucket        = "${var.s3_bucket_name}-${random_id.tc-rmstate.dec}-${random_id.tc-rmstate.dec}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "tf remote state"
  }
}

resource "aws_s3_bucket_object" "rmstate_folder" {
  bucket = "${aws_s3_bucket.tfrmstate.id}"
  key = "terraform-aws/"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name = "${var.aws_dynamodb_table}-${random_id.tc-rmstate.dec}"
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}