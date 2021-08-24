output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnets_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnets_ids" {
  value = "${aws_subnet.private_subnet.*.id}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.vpc.*.cidr_block, [""])[0]
}

output "vpc_default_sg_id" {
  value       = "${aws_security_group.default.id}"
}