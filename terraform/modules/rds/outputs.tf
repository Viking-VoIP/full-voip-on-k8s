output "db_instance_data" {
  description = "The address of the RDS instance"
  value       = module.rds_mysql
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds_mysql.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = module.rds_mysql.db_instance_arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_mysql.db_instance_endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = module.rds_mysql.db_instance_name
}
