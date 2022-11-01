variable "cluster_name" {
    description = "Cluster Name"
}

variable "kubernetes_version" {
    description = "Kubernetes veersion as per AWS specs"
}

variable "region" {
  description = "AWS Deployment region.."
}

variable "vpc_id" {
    description = "VPC ID where to deploy the EKS"
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

variable "public_subnets_ids" {
    description = "public_subnets"
}

variable "private_subnets_ids" {
    description = "On what environment is this running?"
}

variable "vpc_default_sg_id" {
    description = "Default VPC secutry group"
}

variable "eks_workers" { 
    type = object({
        support = object({
            instance_type = string
            desired_capacity = string
            min_capacity = string
            max_capacity = string
            disk_size = string
            ssh_key_name = string
        })
        backend = object({
            instance_type = string
            desired_capacity = string
            min_capacity = string
            max_capacity = string
            disk_size = string
            ssh_key_name = string
        })
        sip-proxy = object({
            instance_type = string
            desired_capacity = string
            min_capacity = string
            max_capacity = string
            disk_size = string
            ssh_key_name = string
        })
        sip-b2bua = object({
            instance_type = string
            desired_capacity = string
            min_capacity = string
            max_capacity = string
            disk_size = string
            ssh_key_name = string
        })
    })
}
