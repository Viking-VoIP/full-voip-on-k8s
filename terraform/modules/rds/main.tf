provider "aws" {
    region            = "us-east-1"
}

module "rds_mysql" {
    source            = "git::https://github.com/tmknom/terraform-aws-rds-mysql.git?ref=tags/2.0.0"
    identifier        = var.db_instance_name
    engine_version    = var.db_version
    instance_class    = var.db_instance_type
    allocated_storage = var.db_disk_size
    username          = var.db_username
    password          = var.db_password

    subnet_ids         = var.public_subnets
    vpc_id             = var.vpc_id
    #source_cidr_blocks = tolist(module.vpc.vpc_cidr_block)
    source_cidr_blocks = [ "10.0.0.0/16" ]

    maintenance_window                  = "mon:10:10-mon:10:40"
    backup_window                       = "09:10-09:40"
    apply_immediately                   = false
    multi_az                            = false
    port                                = 3306
    name                                = "viking"
    storage_type                        = "gp2"
    iops                                = 0
    auto_minor_version_upgrade          = false
    allow_major_version_upgrade         = false
    backup_retention_period             = 0
    storage_encrypted                   = false
    kms_key_id                          = ""
    deletion_protection                 = false
    final_snapshot_identifier           = "final-snapshot"
    skip_final_snapshot                 = true
    enabled_cloudwatch_logs_exports     = []
    monitoring_interval                 = 0
    monitoring_role_arn                 = ""
    iam_database_authentication_enabled = false
    copy_tags_to_snapshot               = false
    publicly_accessible                 = true
    license_model                       = "general-public-license"
    major_engine_version                = "5.7"
    description                         = "This is the database backend for the VoIP platform"

    tags = {
        Environment = "dev"
    }
}