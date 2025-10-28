########################################
# Data Sources - Availability Domains
########################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  # Get list of ADs - OCI regions have 1-3 ADs
  ad_list = data.oci_identity_availability_domains.ads.availability_domains

  # Common tags
  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Task        = "01-networking"
      Owner       = var.owner
    }
  )

  # Service Gateway OCID for all OCI services
  all_services_id = data.oci_core_services.all_services.services[0].id
}

########################################
# VCN (Virtual Cloud Network)
########################################

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-${var.environment}-vcn"
  dns_label      = var.vcn_dns_label

  freeform_tags = local.common_tags
  defined_tags  = var.defined_tags
}

########################################
# Internet Gateway
########################################

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-igw"
  enabled        = true

  freeform_tags = local.common_tags
  defined_tags  = var.defined_tags
}

########################################
# NAT Gateways (One per AD for HA)
########################################

resource "oci_core_nat_gateway" "main" {
  count = var.enable_nat_gateway ? min(length(var.private_subnet_cidrs), length(local.ad_list)) : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  block_traffic  = var.block_nat_traffic

  freeform_tags = merge(
    local.common_tags,
    {
      AD = local.ad_list[count.index].name
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Service Gateway
########################################

resource "oci_core_service_gateway" "main" {
  count = var.enable_service_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-service-gateway"

  services {
    service_id = local.all_services_id
  }

  freeform_tags = local.common_tags
  defined_tags  = var.defined_tags
}

########################################
# Public Route Table
########################################

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-public-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Public"
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Private Route Tables (One per NAT Gateway)
########################################

resource "oci_core_route_table" "private" {
  count = var.enable_nat_gateway ? min(length(var.private_subnet_cidrs), length(local.ad_list)) : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"

  dynamic "route_rules" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      network_entity_id = oci_core_nat_gateway.main[count.index].id
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
    }
  }

  dynamic "route_rules" {
    for_each = var.enable_service_gateway ? [1] : []
    content {
      network_entity_id = oci_core_service_gateway.main[0].id
      destination       = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Private"
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Database Route Table
########################################

resource "oci_core_route_table" "database" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-database-rt"

  dynamic "route_rules" {
    for_each = var.enable_service_gateway ? [1] : []
    content {
      network_entity_id = oci_core_service_gateway.main[0].id
      destination       = lookup(data.oci_core_services.all_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
    }
  }

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Database"
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Public Security List
########################################

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-public-sl"

  # Egress Rules
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Ingress Rules - HTTP
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Ingress Rules - HTTPS
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  # Ingress Rules - SSH
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  freeform_tags = local.common_tags
  defined_tags  = var.defined_tags
}

########################################
# Private Security List
########################################

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.project_name}-${var.environment}-private-sl"

  # Egress Rules
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  # Ingress Rules - Allow from VCN
  ingress_security_rules {
    protocol  = "all"
    source    = var.vcn_cidr
    stateless = false
  }

  freeform_tags = local.common_tags
  defined_tags  = var.defined_tags
}

########################################
# Public Subnets
########################################

resource "oci_core_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.public_subnet_cidrs[count.index]
  display_name               = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
  dns_label                  = "${var.subnet_dns_label_prefix}pub${count.index + 1}"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  availability_domain        = count.index < length(local.ad_list) ? local.ad_list[count.index].name : null

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Public"
      AD   = count.index < length(local.ad_list) ? local.ad_list[count.index].name : "Regional"
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Private Subnets
########################################

resource "oci_core_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.private_subnet_cidrs[count.index]
  display_name               = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
  dns_label                  = "${var.subnet_dns_label_prefix}prv${count.index + 1}"
  prohibit_public_ip_on_vnic = true
  route_table_id             = var.enable_nat_gateway ? oci_core_route_table.private[count.index].id : oci_core_route_table.private[0].id
  security_list_ids          = [oci_core_security_list.private.id]
  availability_domain        = count.index < length(local.ad_list) ? local.ad_list[count.index].name : null

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Private"
      AD   = count.index < length(local.ad_list) ? local.ad_list[count.index].name : "Regional"
    }
  )
  defined_tags = var.defined_tags
}

########################################
# Database Subnets
########################################

resource "oci_core_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = var.database_subnet_cidrs[count.index]
  display_name               = "${var.project_name}-${var.environment}-database-subnet-${count.index + 1}"
  dns_label                  = "${var.subnet_dns_label_prefix}db${count.index + 1}"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.database.id
  security_list_ids          = [oci_core_security_list.private.id]
  availability_domain        = count.index < length(local.ad_list) ? local.ad_list[count.index].name : null

  freeform_tags = merge(
    local.common_tags,
    {
      Tier = "Database"
      AD   = count.index < length(local.ad_list) ? local.ad_list[count.index].name : "Regional"
    }
  )
  defined_tags = var.defined_tags
}
