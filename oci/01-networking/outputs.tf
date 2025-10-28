########################################
# VCN Outputs
########################################

output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.main.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = var.vcn_cidr
}

output "vcn_display_name" {
  description = "Display name of the VCN"
  value       = oci_core_vcn.main.display_name
}

########################################
# Subnet Outputs
########################################

output "public_subnet_ids" {
  description = "OCIDs of public subnets"
  value       = oci_core_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "OCIDs of private subnets"
  value       = oci_core_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "OCIDs of database subnets"
  value       = oci_core_subnet.database[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = oci_core_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = oci_core_subnet.private[*].cidr_block
}

output "database_subnet_cidrs" {
  description = "CIDR blocks of database subnets"
  value       = oci_core_subnet.database[*].cidr_block
}

########################################
# Gateway Outputs
########################################

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "OCIDs of NAT Gateways"
  value       = var.enable_nat_gateway ? oci_core_nat_gateway.main[*].id : []
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway"
  value       = var.enable_service_gateway ? oci_core_service_gateway.main[0].id : null
}

########################################
# Route Table Outputs
########################################

output "public_route_table_id" {
  description = "OCID of public route table"
  value       = oci_core_route_table.public.id
}

output "private_route_table_ids" {
  description = "OCIDs of private route tables"
  value       = oci_core_route_table.private[*].id
}

output "database_route_table_id" {
  description = "OCID of database route table"
  value       = oci_core_route_table.database.id
}

########################################
# Security List Outputs
########################################

output "public_security_list_id" {
  description = "OCID of public security list"
  value       = oci_core_security_list.public.id
}

output "private_security_list_id" {
  description = "OCID of private security list"
  value       = oci_core_security_list.private.id
}

########################################
# Availability Domain Outputs
########################################

output "availability_domains" {
  description = "List of availability domains"
  value       = data.oci_identity_availability_domains.ads.availability_domains[*].name
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
