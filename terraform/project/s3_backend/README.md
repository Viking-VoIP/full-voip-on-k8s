# Terraform Backend Configuration
S3 Backend Configuration for Terraform State

Issue this command when initializing the project:

`make init`

Once init'ed, apply with:

`make apply`

This project will create the necessary S3 bucket and DynamoDB backend for Terraform. 
- It will create an S3 bucket as `terraform-bucket-lock-XXXXXXXXXX`
- It will create a DynamoDB table named `tf-remote-state-lock-XXXXXXXXXX`

 Where `XXXXXXXXXX` will be random numbers (same for both) so as not to conflict with existing buckets out there in the wild.

 Then it will set the s3 backend on the `main` project by sed'ing `../main/main.tf.template` into `../main/main.tf`.

__Note:__ Bucket Name random digits will be changed

