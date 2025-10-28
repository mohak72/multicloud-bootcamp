########################################
# VPC Outputs
########################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

########################################
# Subnet Outputs
########################################

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "db_subnet_group_name" {
  description = "Name of DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_cidrs" {
  description = "CIDR blocks of database subnets"
  value       = aws_subnet.database[*].cidr_block
}

########################################
# Internet Gateway Outputs
########################################

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

########################################
# NAT Gateway Outputs
########################################

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_eip_public_ips" {
  description = "Public IPs of NAT Gateway Elastic IPs"
  value       = aws_eip.nat[*].public_ip
}

########################################
# Route Table Outputs
########################################

output "public_route_table_id" {
  description = "ID of public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of database route table"
  value       = aws_route_table.database.id
}

########################################
# Flow Logs Outputs
########################################

output "flow_log_id" {
  description = "ID of VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.main[0].id : null
}

output "flow_log_cloudwatch_log_group" {
  description = "CloudWatch Log Group for Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

########################################
# Availability Zones
########################################

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

########################################
# Tags
########################################

output "common_tags" {
  description = "Common tags applied to resources"
  value = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
