########################################
# OCI Authentication Variables
########################################

variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file"
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

########################################
# General Variables
########################################

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "multicloud-bootcamp"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "bootcamp-student"
}

########################################
# VCN Variables
########################################

variable "vcn_cidr" {
  description = "CIDR block for VCN (RFC 1918 compliant)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "DNS label for VCN"
  type        = string
  default     = "bootcampvcn"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,14}$", var.vcn_dns_label))
    error_message = "DNS label must start with a letter and contain only lowercase alphanumeric characters (max 15 chars)."
  }
}

########################################
# Subnet Variables
########################################

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "subnet_dns_label_prefix" {
  description = "Prefix for subnet DNS labels"
  type        = string
  default     = "subnet"
}

########################################
# Gateway Variables
########################################

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_service_gateway" {
  description = "Enable Service Gateway for OCI services"
  type        = bool
  default     = true
}

variable "block_nat_traffic" {
  description = "Block NAT traffic from private subnets"
  type        = bool
  default     = false
}

########################################
# Security Variables
########################################

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidrs" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########################################
# Flow Logs Variables
########################################

variable "enable_flow_logs" {
  description = "Enable VCN Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7
}

########################################
# Additional Variables
########################################

variable "tags" {
  description = "Freeform tags for all resources"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags for all resources"
  type        = map(string)
  default     = {}
}
