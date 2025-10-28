# Task 1: Virtual Networking - AWS

## Objective
Set up complete virtual network on AWS cloud platform with production-grade best practices.

## What You'll Build

### Architecture Components
```
┌─────────────────────────────────────────────────┐
│                  AWS Region                      │
│  ┌────────────────────────────────────────────┐ │
│  │           VPC (10.0.0.0/16)                │ │
│  │                                            │ │
│  │  ┌──────────────┐    ┌──────────────┐    │ │
│  │  │  Public      │    │  Public      │    │ │
│  │  │  Subnet      │    │  Subnet      │    │ │
│  │  │  10.0.1.0/24 │    │  10.0.2.0/24 │    │ │
│  │  │  AZ-1        │    │  AZ-2        │    │ │
│  │  └──────┬───────┘    └──────┬───────┘    │ │
│  │         │                   │            │ │
│  │  ┌──────▼───────┐    ┌──────▼───────┐    │ │
│  │  │  Private     │    │  Private     │    │ │
│  │  │  Subnet      │    │  Subnet      │    │ │
│  │  │  10.0.11.0/24│    │  10.0.12.0/24│    │ │
│  │  │  AZ-1        │    │  AZ-2        │    │ │
│  │  └──────────────┘    └──────────────┘    │ │
│  │                                            │ │
│  │  Internet Gateway    NAT Gateways (2)     │ │
│  │  Route Tables (4)    Flow Logs           │ │
│  └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## Components

### 1. VPC (Virtual Private Cloud)
- **CIDR**: 10.0.0.0/16 (RFC 1918 compliant)
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled
- **Tenancy**: Default

### 2. Subnets
- **Public Subnets** (2):
  - `10.0.1.0/24` (AZ-1) - For ALB, Bastion
  - `10.0.2.0/24` (AZ-2) - For ALB, High Availability

- **Private Subnets** (2):
  - `10.0.11.0/24` (AZ-1) - For Application Servers
  - `10.0.12.0/24` (AZ-2) - For Application Servers

- **Database Subnets** (2):
  - `10.0.21.0/24` (AZ-1) - For RDS
  - `10.0.22.0/24` (AZ-2) - For RDS

### 3. Internet Gateway
- Attached to VPC
- Enables internet access for public subnets

### 4. NAT Gateways (High Availability)
- NAT Gateway in each public subnet (2 total)
- Elastic IPs for each NAT Gateway
- Allows private subnets to access internet

### 5. Route Tables
- **Public Route Table**:
  - Routes to Internet Gateway (0.0.0.0/0)
  - Associated with public subnets

- **Private Route Tables** (2):
  - Routes to respective NAT Gateways
  - Associated with private subnets

- **Database Route Table**:
  - No internet access (isolated)
  - Associated with database subnets

### 6. VPC Flow Logs
- **Destination**: CloudWatch Logs
- **Traffic Type**: ALL (Accept + Reject)
- **Log Format**: Default
- **Retention**: 7 days

### 7. Network ACLs (NACLs)
- Default allow rules
- Stateless firewall

### 8. Security Groups
- Will be created in subsequent tasks

## Files Structure

```
01-networking/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example variables
├── backend.tf              # Remote state configuration
├── provider.tf             # AWS provider configuration
├── vpc.tf                  # VPC resources
├── subnets.tf              # Subnet resources
├── internet-gateway.tf     # IGW resources
├── nat-gateway.tf          # NAT Gateway resources
├── route-tables.tf         # Route table resources
├── flow-logs.tf            # VPC Flow Logs
└── README.md               # This file
```

## Prerequisites

1. **AWS CLI configured** with credentials
2. **Terraform installed** (v1.6+)
3. **AWS Account** with appropriate permissions
4. **S3 bucket** for Terraform state (optional but recommended)

## Usage

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review Plan

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

### 5. Verify Deployment

```bash
# Get VPC ID
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=bootcamp-vpc"

# Get Subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"

# Check Flow Logs
aws ec2 describe-flow-logs --filter "Name=resource-type,Values=VPC"
```

### 6. Test Connectivity

```bash
# Test from within the VPC (requires bastion host)
# This will be covered in later tasks
```

### 7. Destroy Infrastructure

```bash
terraform destroy
```

## What You'll Learn

1. **RFC 1918 IP Addressing**:
   - Private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
   - CIDR notation and subnetting
   - IP address planning

2. **High Availability**:
   - Multi-AZ deployment
   - Redundant NAT Gateways
   - Fault tolerance

3. **Network Segmentation**:
   - Public vs Private subnets
   - Database subnet isolation
   - Security boundaries

4. **Routing**:
   - Route table configuration
   - Internet Gateway routing
   - NAT Gateway routing

5. **Observability**:
   - VPC Flow Logs
   - Network traffic monitoring
   - Troubleshooting network issues

## Best Practices Implemented

✅ Multi-AZ deployment for high availability
✅ Separate subnets for different tiers (public, private, database)
✅ NAT Gateways in each AZ for redundancy
✅ VPC Flow Logs for network monitoring
✅ RFC 1918 compliant IP addressing
✅ Proper tagging for resource management
✅ Remote state storage with encryption
✅ Cost-optimized design

## Cost Estimation

Approximate monthly costs (us-east-1):
- VPC: Free
- NAT Gateways: ~$65/month (2 gateways)
- VPC Flow Logs: ~$5/month
- Data Transfer: Variable

**Total: ~$70-80/month**

💡 **Cost Savings**: For development, you can use a single NAT Gateway (~$32.50/month)

## Troubleshooting

### Issue: Terraform init fails
```bash
# Solution: Check AWS credentials
aws sts get-caller-identity
```

### Issue: No available IP addresses
```bash
# Solution: Check CIDR blocks don't overlap
aws ec2 describe-vpcs
```

### Issue: NAT Gateway creation fails
```bash
# Solution: Ensure public subnet has IGW route
aws ec2 describe-route-tables
```

## Next Steps

After completing this task:
1. ✅ Verify VPC and subnets are created
2. ✅ Check Flow Logs are active
3. ✅ Validate route tables
4. ➡️ Proceed to **Task 2: Load Balancing**

## Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [RFC 1918 - Address Allocation](https://tools.ietf.org/html/rfc1918)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Duration**: 2-3 hours
**Difficulty**: Beginner
**Prerequisites**: Basic AWS knowledge
