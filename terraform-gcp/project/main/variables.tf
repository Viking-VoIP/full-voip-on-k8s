variable "gcp_credentials" {
    type = string
    default = "/Users/david.villasmil/deployer-laptop-tn-gcp-creds-viking-voip.json"
}

variable "gcp_project_id" {
    type = string
}

variable "gcp_region" {
    type = string
}

variable "gcp_zone" {
    type = string
}

variable "gcp_cluster_name" {
    type = string
}

variable "gcp_is_regional" {
    type = bool
    default = false
}

variable "gcp_network_name" {
    type = string
}

variable "gcp_subnetwork_name" {
    type = string
}

variable "gcp_service_account" {
    type = string
    default = "deployer-david@viking-voip.iam.gserviceaccount.com"
}

variable "gcp_database_version" {
    type = string
    default = "MYSQL_5_7"
}

variable "gks_workers" { 
    type = object({
        support = object({
            machine_type = string
            min_capacity = string
            max_capacity = string
            disk_size = string
        })
        backend = object({
            machine_type = string
            min_capacity = string
            max_capacity = string
            disk_size = string
        })
        sip-proxy = object({
            machine_type = string
            min_capacity = string
            max_capacity = string
            disk_size = string
        })
        sip-b2bua = object({
            machine_type = string
            min_capacity = string
            max_capacity = string
            disk_size = string
        })
    })
}
