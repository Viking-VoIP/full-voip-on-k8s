output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_default_sg_id" {
  description = "We need the VPC's default SG"
  value       = module.vpc.vpc_default_sg_id
}

output "db_instance_data" {
  description = "The address of the RDS instance"
  value       = module.rds
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds.db_instance_endpoint 
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds.db_instance_name
}
