terraform {
  backend "gcs" {
      bucket = "my-terraform-storage-bucket"
      prefix = "workspaces"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.66"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "google" {
    credentials = file(var.gcp_credentials)
    project = var.gcp_project_id
    region = var.gcp_region
}

resource "random_integer" "int" {
  min = 100
  max = 1000000
}

module "my_vpc" {
  source                  = "../../modules/vpc"
  gcp_network_name        = "my-default-vpc"
  gcp_project_id          = var.gcp_project_id
}

module "terraform-google-sql-db" {
  source                  = "../../modules/mysql"
  project_id              = var.gcp_project_id
  name                    = "vikingdb"
  random_instance_name    = false
  database_version        = var.gcp_database_version
  region                  = var.gcp_region
  tier                    = "db-n1-standard-1"
  zone                    = var.gcp_zone
  private_network         = module.my_vpc.vpc_link
}

//module "terraform-google-gks" {
//  source                  = "../../modules/gks"
//  gcp_project_id          = var.gcp_project_id
//  gcp_zone                = var.gcp_zone
//  gcp_network_name        = var.gcp_network_name
//  gcp_region              = var.gcp_region
//  gcp_cluster_name        = var.gcp_cluster_name
//  gcp_subnetwork_name     = var.gcp_subnetwork_name
//  gks_workers             = var.gks_workers
//}