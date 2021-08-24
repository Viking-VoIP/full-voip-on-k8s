variable "region" {
  description   = "AWS Deployment region.."
  default       = "us-east-1"
}

variable "vpc_cidr" {
    description = "CIDR to assign to this VPC"
}

variable "environment" {
    description = "On what environment is this running?"
}

variable "availability_zones" {
    description = "On what environment is this running?"
}

variable "public_subnets_cidr" {
    description = "public_subnets_cidr"
}

variable "private_subnets_cidr" {
    description = "On what environment is this running?"
}
