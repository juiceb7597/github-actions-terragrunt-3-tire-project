################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.main[0].id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.main[0].arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.main[0].cidr_block, null)
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(aws_vpc.main[0].owner_id, null)
}

################################################################################
# Publiс Subnets
################################################################################

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = compact(aws_subnet.public[*].cidr_block)
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route"
  value       = try(aws_route.public_internet_gateway[0].id, null)
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public[*].id
}

################################################################################
# WEB Subnets
################################################################################

output "web_subnets" {
  description = "List of IDs of WEB subnets"
  value       = aws_subnet.web[*].id
}

output "web_subnet_arns" {
  description = "List of ARNs of WEB subnets"
  value       = aws_subnet.web[*].arn
}

output "web_subnets_cidr_blocks" {
  description = "List of cidr_blocks of WEB subnets"
  value       = compact(aws_subnet.web[*].cidr_block)
}

output "web_route_table_ids" {
  description = "List of IDs of web route tables"
  value       = aws_route_table.web[*].id
}

output "web_nat_gateway_route_ids" {
  description = "List of IDs of the web nat gateway route"
  value       = aws_route.web_nat_gateway[*].id
}

output "web_route_table_association_ids" {
  description = "List of IDs of the web route table association"
  value       = aws_route_table_association.web[*].id
}

################################################################################
# WAS Subnets
################################################################################

output "was_subnets" {
  description = "List of IDs of WAS subnets"
  value       = aws_subnet.was[*].id
}

output "was_subnet_arns" {
  description = "List of ARNs of WAS subnets"
  value       = aws_subnet.was[*].arn
}

output "was_subnets_cidr_blocks" {
  description = "List of cidr_blocks of WAS subnets"
  value       = compact(aws_subnet.was[*].cidr_block)
}

output "was_route_table_ids" {
  description = "List of IDs of was route tables"
  value       = aws_route_table.web[*].id
}

output "was_route_table_association_ids" {
  description = "List of IDs of the was route table association"
  value       = aws_route_table_association.was[*].id
}

################################################################################
# DB Subnets
################################################################################

output "db_subnets" {
  description = "List of IDs of DB subnets"
  value       = aws_subnet.db[*].id
}

output "db_subnet_arns" {
  description = "List of ARNs of DB subnets"
  value       = aws_subnet.db[*].arn
}

output "db_subnets_cidr_blocks" {
  description = "List of cidr_blocks of DB subnets"
  value       = compact(aws_subnet.db[*].cidr_block)
}

output "db_route_table_ids" {
  description = "List of IDs of db route tables"
  value       = aws_route_table.web[*].id
}

output "db_route_table_association_ids" {
  description = "List of IDs of the db route table association"
  value       = aws_route_table_association.db[*].id
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].arn, null)
}

################################################################################
# NAT Gateway
################################################################################

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

################################################################################
# Static values (arguments)
################################################################################

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}