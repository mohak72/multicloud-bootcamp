# Task 1: Virtual Networking - Oracle Cloud Infrastructure (OCI)

## Objective
Set up complete virtual network on OCI cloud platform with production-grade best practices.

## What You'll Build

### Architecture Components
```
┌─────────────────────────────────────────────────┐
│                  OCI Region                      │
│  ┌────────────────────────────────────────────┐ │
│  │      VCN (Virtual Cloud Network)           │ │
│  │           10.0.0.0/16                      │ │
│  │                                            │ │
│  │  ┌──────────────┐    ┌──────────────┐    │ │
│  │  │  Public      │    │  Public      │    │ │
│  │  │  Subnet      │    │  Subnet      │    │ │
│  │  │  10.0.1.0/24 │    │  10.0.2.0/24 │    │ │
│  │  │  AD-1        │    │  AD-2        │    │ │
│  │  └──────┬───────┘    └──────┬───────┘    │ │
│  │         │                   │            │ │
│  │  ┌──────▼───────┐    ┌──────▼───────┐    │ │
│  │  │  Private     │    │  Private     │    │ │
│  │  │  Subnet      │    │  Subnet      │    │ │
│  │  │  10.0.11.0/24│    │  10.0.12.0/24│    │ │
│  │  │  AD-1        │    │  AD-2        │    │ │
│  │  └──────────────┘    └──────────────┘    │ │
│  │                                            │ │
│  │  Internet Gateway    NAT Gateways (2)     │ │
│  │  Route Tables (3)    Flow Logs           │ │
│  │  Security Lists                           │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## Components

### 1. VCN (Virtual Cloud Network)
- **CIDR**: 10.0.0.0/16 (RFC 1918 compliant)
- **DNS Label**: bootcampvcn
- **Compartment**: Root or custom compartment

### 2. Subnets
- **Public Subnets** (2):
  - `10.0.1.0/24` (AD-1) - For Load Balancers
  - `10.0.2.0/24` (AD-2) - For Load Balancers

- **Private Subnets** (2):
  - `10.0.11.0/24` (AD-1) - For Application Servers
  - `10.0.12.0/24` (AD-2) - For Application Servers

- **Database Subnets** (2):
  - `10.0.21.0/24` (AD-1) - For OCI Database
  - `10.0.22.0/24` (AD-2) - For OCI Database

### 3. Internet Gateway
- Attached to VCN
- Enables internet access for public subnets

### 4. NAT Gateways (High Availability)
- NAT Gateway for each AD (2 total)
- Allows private subnets to access internet

### 5. Service Gateway
- Access to OCI Services (Object Storage, etc.)
- No internet gateway required

### 6. Route Tables
- **Public Route Table**:
  - Routes to Internet Gateway (0.0.0.0/0)
  - Associated with public subnets

- **Private Route Tables**:
  - Routes to NAT Gateway
  - Routes to Service Gateway
  - Associated with private subnets

- **Database Route Table**:
  - Route to Service Gateway only
  - Associated with database subnets

### 7. Security Lists
- Default security list for VCN
- Custom security lists for each tier
- Stateful firewall rules

### 8. Network Security Groups (NSGs)
- Fine-grained security controls
- Applied at VNIC level

### 9. VCN Flow Logs
- **Destination**: OCI Logging Service
- **Traffic Type**: ALL
- **Log Type**: FlowLog

## Files Structure

```
01-networking/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variables
├── provider.tf             # OCI provider configuration
├── vcn.tf                  # VCN resources
├── subnets.tf              # Subnet resources
├── gateways.tf             # IGW, NAT, Service Gateway
├── route-tables.tf         # Route table resources
├── security.tf             # Security Lists and NSGs
├── flow-logs.tf            # VCN Flow Logs
└── README.md               # This file
```

## Prerequisites

1. **OCI CLI configured** with credentials
2. **Terraform installed** (v1.6+)
3. **OCI Account** with appropriate permissions
4. **Compartment OCID** (use root or create new)
5. **Tenancy OCID** from OCI Console

## OCI-Specific Concepts

### Availability Domains (ADs)
- Physical data centers within a region
- Similar to AWS Availability Zones
- Number varies by region (1-3 ADs)

### Compartments
- Logical containers for organizing resources
- Enable access control and cost tracking
- Can be hierarchical

### OCIDs
- Oracle Cloud Identifiers
- Unique identifiers for all resources
- Format: ocid1.{resource-type}.{realm}.{region}.{unique-id}

## Usage

### 1. Get Your OCI Credentials

```bash
# Get Tenancy OCID
oci iam tenancy get --tenancy-id <your-tenancy-ocid>

# Get Compartment OCID (use root compartment or create new)
oci iam compartment list --all

# Get your user OCID
oci iam user list --all
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCIDs
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review Plan

```bash
terraform plan
```

### 5. Deploy Infrastructure

```bash
terraform apply
```

### 6. Verify Deployment

```bash
# Get VCN details
oci network vcn list --compartment-id <compartment-ocid>

# Get Subnets
oci network subnet list --compartment-id <compartment-ocid>

# Check NAT Gateways
oci network nat-gateway list --compartment-id <compartment-ocid>
```

### 7. Destroy Infrastructure

```bash
terraform destroy
```

## Key Differences: AWS vs OCI

| Feature | AWS | OCI |
|---------|-----|-----|
| Network | VPC | VCN |
| Availability | AZ (Availability Zone) | AD (Availability Domain) |
| Firewall | Security Groups | Security Lists + NSGs |
| NAT | NAT Gateway ($$$) | NAT Gateway (FREE!) |
| Routing | Route Tables | Route Tables |
| DNS | Route 53 | OCI DNS |
| Region Codes | us-east-1 | us-ashburn-1 |

## Cost Estimation

Approximate monthly costs:
- VCN: **FREE**
- NAT Gateways: **FREE** (Unlike AWS!)
- Internet Gateway: **FREE**
- Subnets: **FREE**
- Flow Logs: ~$1/month
- Data Transfer: Variable

**Total: ~$1-5/month** (Much cheaper than AWS!)

💡 **Major Cost Advantage**: OCI NAT Gateway is FREE (vs ~$65/month in AWS)

## Best Practices Implemented

✅ Multi-AD deployment for high availability
✅ Separate subnets for different tiers
✅ NAT Gateways for private subnet internet access
✅ Service Gateway for OCI service access
✅ VCN Flow Logs for monitoring
✅ RFC 1918 compliant IP addressing
✅ Proper tagging for resource management
✅ Security Lists and NSGs for defense in depth

## Troubleshooting

### Issue: OCI CLI not configured
```bash
# Solution: Run setup
oci setup config
```

### Issue: Insufficient permissions
```bash
# Solution: Check IAM policies in OCI Console
# Required: manage virtual-network-family
```

### Issue: Availability Domain not found
```bash
# Solution: List available ADs for your region
oci iam availability-domain list
```

## Next Steps

After completing this task:
1. ✅ Verify VCN and subnets are created
2. ✅ Check Flow Logs are active
3. ✅ Validate route tables and gateways
4. ➡️ Proceed to **Task 2: Load Balancing**

## Resources

- [OCI VCN Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [RFC 1918 - Address Allocation](https://tools.ietf.org/html/rfc1918)
- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)

---

**Duration**: 2-3 hours
**Difficulty**: Beginner
**Prerequisites**: Basic OCI knowledge
