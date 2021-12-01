output "S3_Bucket" {
    value = "${aws_s3_bucket.tfrmstate.id}"
}

output "dynamo_db_lock" {
    value = "${aws_dynamodb_table.terraform_statelock.name}"
}

output "ssh_keypair" {
    sensitive = true
    value = "${tls_private_key.private_key}"
}