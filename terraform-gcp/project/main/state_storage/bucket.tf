resource "google_storage_bucket" "my-terraform-storage-bucket" {
  name     = "my-terraform-storage-bucket"
  location = "us-east1"
}