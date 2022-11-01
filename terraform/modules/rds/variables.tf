variable "db_instance_type" {
    type = string
}

variable "db_version" {
    type = string
}

variable "db_disk_size" {
    type = string
}

variable "db_username" {
    type = string
}

variable "db_password" {
    type = string
}

variable "public_subnets" {
    type = list(string)
}

variable "vpc_id" {
    type = string
}

variable "db_instance_name" {
    type = string
}
