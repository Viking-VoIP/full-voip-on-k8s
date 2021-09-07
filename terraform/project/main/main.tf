terraform {
  backend "s3" {
    region = "us-east-1"
    encrypt = true
    bucket = "terraform-bucket-lock-1714561171"
    key    = "terraform-state"
    dynamodb_table = "tf-remote-state-lock-1714561171"
  }
}

module "vpc" {
  source                = "../../modules/vpc"
  region                = var.region
  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
  availability_zones    = var.availability_zones
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
}

module "rds" {
  source                = "../../modules/rds"
  db_instance_name      = var.db_instance_name
  db_instance_type      = var.db_instance_type
  db_disk_size          = var.db_disk_size
  db_username           = var.db_username
  db_password           = var.db_password
  public_subnets        = module.vpc.private_subnets_ids
  vpc_id                = module.vpc.vpc_id
}

module "eks" {
  source                = "../../modules/eks"
  cluster_name          = var.eks_cluster_name
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
  availability_zones    = var.availability_zones
  public_subnets_ids    = module.vpc.public_subnets_ids
  private_subnets_ids   = module.vpc.private_subnets_ids
  eks_workers           = var.eks_workers
  vpc_default_sg_id     = module.vpc.vpc_default_sg_id
}
