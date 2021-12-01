variable "aws_region" {
    default = "us-east-1"
}
variable "aws_dynamodb_table" {
  default = "tf-remote-state-lock"
}

variable "s3_bucket_name" {
  default = "terraform-bucket-lock"
}

variable "key_name" {
  default = "ssh_keypair_name"
}
