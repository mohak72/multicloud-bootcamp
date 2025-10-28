# Multi-Cloud Infrastructure Bootcamp

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![OCI](https://img.shields.io/badge/Oracle-Cloud-F80000?logo=oracle)](https://www.oracle.com/cloud/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive hands-on bootcamp for mastering multi-cloud infrastructure using AWS and Oracle Cloud Infrastructure (OCI) with Terraform.

## 📚 Project Overview

This repository contains 22+ production-grade infrastructure projects covering:

- **Networking**: VPC, Subnets, VPN, Private Links
- **Compute**: VMs, Autoscaling, Spot Instances, Batch Processing
- **Load Balancing**: ALB, NLB, Application Gateway
- **Databases**: RDS, Aurora, MySQL Master-Slave
- **Serverless**: Lambda, Event-Driven Architecture, Data Lakes
- **Security**: IAM, Zero Trust, Cross-Account Access, WAF
- **Storage**: S3, Cross-Region/Account Replication
- **API Management**: API Gateway, REST APIs

## 🏗️ Repository Structure

```
multicloud-bootcamp/
├── aws/                    # AWS Infrastructure
│   ├── 01-networking/      # VPC, Subnets, IGW, NAT, Flow Logs
│   ├── 02-load-balancing/  # ALB/NLB configurations
│   ├── 03-autoscaling/     # Auto Scaling Groups
│   ├── 04-privatelink/     # Private Endpoints
│   ├── 05-vpn/             # VPN configurations
│   ├── 06-database/        # RDS, Aurora
│   ├── 07-serverless/      # Lambda, EventBridge, Data Lakes
│   ├── 08-compute/         # EC2, Spot, Batch
│   ├── 09-iam/             # IAM Policies, Roles
│   ├── 10-storage/         # S3, Replication
│   └── modules/            # Reusable Terraform modules
│
├── oci/                    # Oracle Cloud Infrastructure
│   ├── 01-networking/      # VCN, Subnets, Gateways
│   ├── 02-load-balancing/  # OCI Load Balancers
│   ├── 03-autoscaling/     # Instance Pools, Autoscaling
│   ├── 04-privatelink/     # Private Endpoints
│   ├── 05-vpn/             # VPN configurations
│   ├── 06-database/        # OCI Database Services
│   ├── 07-compute/         # Compute Instances
│   ├── 08-iam/             # IAM Policies
│   ├── 09-storage/         # Object Storage
│   └── modules/            # Reusable Terraform modules
│
├── shared/                 # Shared utilities
│   ├── scripts/            # Helper scripts
│   └── policies/           # Common policies
│
├── docs/                   # Documentation
│   ├── setup/              # Setup guides
│   ├── tasks/              # Task-specific docs
│   └── troubleshooting/    # Common issues
│
└── .github/                # GitHub Actions workflows
    └── workflows/          # CI/CD pipelines
```

## 🚀 Quick Start

### Prerequisites

1. **Install Required Tools**:
   ```bash
   # Terraform
   # AWS CLI
   # OCI CLI
   # Git
   ```

2. **Configure Cloud Credentials**:
   ```bash
   # AWS
   aws configure

   # OCI
   oci setup config
   ```

3. **Clone and Initialize**:
   ```bash
   git clone <your-repo-url>
   cd multicloud-bootcamp
   ```

### Running Your First Project

```bash
# Navigate to a project
cd aws/01-networking

# Initialize Terraform
terraform init

# Plan infrastructure
terraform plan

# Apply infrastructure
terraform apply

# Destroy when done
terraform destroy
```

## 📖 Bootcamp Tasks

### Phase 1: Networking Foundations
- [x] Task 1: Virtual Networking (VPC/VNet, Subnets, Route Tables)
- [ ] Task 4: Private Link/Private Endpoint
- [ ] Task 8: Multi-Cloud Redundant VPN with BGP
- [ ] Task 9: Non-BGP Hub-and-Spoke VPN Mesh

### Phase 2: Compute & Load Balancing
- [ ] Task 2: ALB with NGINX VMs
- [ ] Task 5: AWS NLB vs ALB Comparison
- [ ] Task 7: Full-Featured ALB with WAF
- [ ] Task 21: Azure Application Gateway (Layer 7)

### Phase 3: Auto Scaling
- [ ] Task 3: Basic Autoscaling Setup
- [ ] Task 10: Autoscaling with Custom Metrics
- [ ] Task 11: Zero-Downtime Deployment

### Phase 4: Databases
- [ ] Task 12: Fine-tuning MySQL RDS
- [ ] Task 13: Master-Slave MySQL RDS
- [ ] Task 14: Aurora DB Deployment

### Phase 5: Serverless
- [ ] Task 15: Event-Driven Microservice
- [ ] Task 16: Cloud-Native Data Lake
- [ ] Task 22: Secure REST API with API Gateway

### Phase 6: Advanced Compute
- [ ] Task 17: Scalable Compute Cluster for ML/Batch
- [ ] Task 18: VM Disk Lifecycle Management

### Phase 7: Security & IAM
- [ ] Task 19: Zero Trust to Cross-Cloud Federation

### Phase 8: Storage
- [ ] Task 20: S3 Cross-Region & Cross-Account Replication

## 🔧 Development Workflow

### Using GitHub Actions (Recommended for Production)

1. Create feature branch
2. Make changes
3. Push to GitHub
4. GitHub Actions runs `terraform plan`
5. Review and merge PR
6. GitHub Actions runs `terraform apply`

### Local Development

```bash
# Run Terraform locally
cd <project-directory>
terraform init
terraform plan
terraform apply
```

## 🏃 Self-Hosted GitHub Actions Runners

### Local Runner Setup

```bash
# Navigate to runner directory
cd shared/scripts

# Run setup script
./setup-github-runner.sh
```

### Cloud Runner Setup

Deploy runners on EC2 (AWS) or Compute Instances (OCI) for production workloads.

See: `docs/setup/github-runners.md`

## 🔐 Security Best Practices

- ✅ Never commit secrets or credentials
- ✅ Use Terraform remote state with encryption
- ✅ Implement least privilege IAM policies
- ✅ Enable flow logs and audit logging
- ✅ Use private subnets for resources
- ✅ Enable encryption at rest and in transit
- ✅ Regular security scanning with tfsec/checkov

## 💰 Cost Management

- Use tags for resource tracking
- Implement auto-shutdown for dev resources
- Use spot instances where applicable
- Set up billing alerts
- Regular cost reviews

## 📚 Additional Resources

- [AWS Documentation](https://docs.aws.amazon.com/)
- [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Terraform Registry](https://registry.terraform.io/)
- [Best Practices Guide](docs/best-practices.md)

## 🤝 Contributing

1. Create feature branch
2. Make changes following style guide
3. Test thoroughly
4. Submit PR with description

## 📝 License

MIT License - See LICENSE file for details

## 👤 Author

Multi-Cloud Infrastructure Bootcamp Project

---

**Happy Learning! 🚀**
