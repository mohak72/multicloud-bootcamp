# Getting Started with Multi-Cloud Bootcamp 🚀

Welcome to your multi-cloud infrastructure bootcamp! This guide will help you get started with your first task.

## 📋 Prerequisites Checklist

Before you begin, ensure you have:

### Required Tools
- [ ] **Git** installed and configured
- [ ] **Terraform** (v1.6+) installed
- [ ] **Code Editor** (VS Code recommended)

### Cloud Accounts
- [ ] **AWS Account** with access credentials
- [ ] **Oracle Cloud (OCI) Account** with access credentials

### Command Line Tools
- [ ] **AWS CLI** installed and configured
- [ ] **OCI CLI** installed and configured

---

## 🎯 Quick Start (Day 1)

### Step 1: Verify Repository Setup

```bash
# Check you're in the right directory
cd multicloud-bootcamp
ls -la

# You should see:
# - aws/
# - oci/
# - docs/
# - .github/
# - README.md
# - Makefile
```

### Step 2: Configure AWS CLI

```bash
# Run AWS configuration
aws configure

# Enter your credentials:
# AWS Access Key ID: YOUR_ACCESS_KEY_ID
# AWS Secret Access Key: YOUR_SECRET_ACCESS_KEY
# Default region: us-east-1
# Default output format: json

# Test configuration
aws sts get-caller-identity
```

**Need help?** See [docs/setup/aws-cli-setup.md](docs/setup/aws-cli-setup.md)

### Step 3: Configure OCI CLI

```bash
# Run OCI configuration
oci setup config

# Follow prompts to enter:
# - User OCID
# - Tenancy OCID
# - Region
# - Generate RSA key pair

# Test configuration
oci iam user get --user-id YOUR_USER_OCID
```

**Need help?** See [docs/setup/oci-cli-setup.md](docs/setup/oci-cli-setup.md)

### Step 4: Start with Task 1 - AWS Networking

```bash
# Navigate to AWS networking project
cd aws/01-networking

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create the infrastructure (Type 'yes' when prompted)
terraform apply

# After exploring, destroy resources
terraform destroy
```

### Step 5: Repeat for OCI

```bash
# Navigate to OCI networking project
cd ../../oci/01-networking

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values (need OCIDs from OCI Console)
nano terraform.tfvars

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Deploy
terraform apply

# Destroy when done
terraform destroy
```

---

## 🗓️ Suggested Daily Schedule

### Week 1: Foundations
- **Day 1**: Task 1 - Virtual Networking (AWS)
- **Day 2**: Task 1 - Virtual Networking (OCI)
- **Day 3**: Task 2 - Load Balancing with NGINX (AWS)
- **Day 4**: Task 2 - Load Balancing (OCI)
- **Day 5**: Review, documentation, cost analysis

### Week 2: Auto Scaling
- **Day 6**: Task 3 - Basic Autoscaling (AWS)
- **Day 7**: Task 3 - Basic Autoscaling (OCI)
- **Day 8-9**: Advanced autoscaling scenarios
- **Day 10**: Review and optimization

### Week 3: Advanced Networking
- **Day 11-12**: Task 4 - Private Link/Endpoint
- **Day 13-15**: Task 8/9 - VPN configurations

### Week 4: Databases
- **Day 16-18**: Tasks 12-14 - RDS, Aurora, Replication
- **Day 19-20**: Review and optimization

### Week 5: Serverless & Compute
- **Day 21-25**: Tasks 15-18 - Lambda, Data Lakes, Compute

### Week 6: Security & Storage
- **Day 26-28**: Task 19 - IAM, Zero Trust
- **Day 29-30**: Task 20 - S3 Replication

---

## 🛠️ Using the Makefile

The project includes a Makefile for common operations:

```bash
# Show all available commands
make help

# AWS commands
make aws-init PROJECT=01-networking
make aws-plan PROJECT=01-networking
make aws-apply PROJECT=01-networking
make aws-destroy PROJECT=01-networking

# OCI commands
make oci-init PROJECT=01-networking
make oci-plan PROJECT=01-networking
make oci-apply PROJECT=01-networking
make oci-destroy PROJECT=01-networking

# Format all Terraform files
make fmt-all

# Check for required tools
make check-tools
```

---

## 📚 Documentation Structure

```
docs/
├── setup/
│   ├── aws-cli-setup.md          # AWS CLI configuration
│   ├── oci-cli-setup.md          # OCI CLI configuration
│   └── github-runners.md         # Self-hosted runners setup
├── tasks/
│   └── (Task-specific guides)
└── troubleshooting/
    └── (Common issues and solutions)
```

---

## 🔐 Security Best Practices

### Never Commit Secrets!

```bash
# These files should NEVER be committed:
# - terraform.tfvars (contains your credentials)
# - *.pem, *.key (SSH keys, API keys)
# - ~/.aws/credentials
# - ~/.oci/config
```

They're already in `.gitignore` - just don't force add them!

### Use Cost Alerts

**AWS**:
```bash
# Set up billing alerts immediately!
# AWS Console → Billing → Budgets
# Create alerts at: $10, $50, $100
```

**OCI**:
```bash
# OCI Console → Billing & Cost Management → Budgets
# Set budget alerts
```

### Clean Up Resources

```bash
# ALWAYS destroy resources when done experimenting!
cd aws/01-networking
terraform destroy

cd oci/01-networking
terraform destroy
```

---

## 🎓 Learning Tips

### 1. Understand Before Running
- Read the task README first
- Review the architecture diagram
- Understand each resource being created

### 2. Experiment Safely
- Start with small changes
- Use `terraform plan` before `apply`
- Take notes on what you learn

### 3. Track Costs
- Check AWS/OCI billing dashboard daily
- Set up budget alerts immediately
- Destroy resources when not in use

### 4. Document Your Journey
- Keep a learning journal
- Screenshot architectures
- Note problems and solutions

### 5. Ask Questions
- Read documentation thoroughly
- Search for error messages
- Use cloud provider support forums

---

## 🐛 Common Issues

### Terraform init fails
```bash
# Solution: Check internet connection and Terraform version
terraform version
```

### AWS credentials not found
```bash
# Solution: Reconfigure AWS CLI
aws configure
aws sts get-caller-identity
```

### OCI authentication error
```bash
# Solution: Check OCI config and key permissions
cat ~/.oci/config
chmod 600 ~/.oci/oci_api_key.pem
```

### Resource already exists
```bash
# Solution: Import existing resource or use different name
terraform import aws_vpc.main vpc-xxxxxxxxx
```

---

## 📞 Getting Help

### Documentation
- **AWS**: https://docs.aws.amazon.com/
- **OCI**: https://docs.oracle.com/en-us/iaas/
- **Terraform**: https://www.terraform.io/docs

### This Repository
- Check task-specific README files
- Review troubleshooting guides
- Read error messages carefully

### Community
- AWS Forums
- OCI Forums
- Terraform Community
- Stack Overflow

---

## ✅ Daily Checklist Template

Use this checklist for each task:

```
Task: _______________
Date: _______________

[ ] Read task README
[ ] Understand architecture
[ ] Copy terraform.tfvars.example
[ ] Configure variables
[ ] Run terraform init
[ ] Review terraform plan
[ ] Run terraform apply
[ ] Verify resources in console
[ ] Test functionality
[ ] Document learnings
[ ] Run terraform destroy
[ ] Verify cleanup in console
[ ] Check costs

Notes:
- What I learned:
- Challenges faced:
- Time taken:
- Cost incurred:
```

---

## 🎉 Ready to Start?

You're all set! Begin with:

```bash
cd aws/01-networking
cat README.md
```

**Good luck and happy learning!** 🚀

---

## 📊 Progress Tracking

Mark off tasks as you complete them:

### Phase 1: Networking
- [ ] Task 1: Virtual Networking (AWS)
- [ ] Task 1: Virtual Networking (OCI)
- [ ] Task 4: Private Link
- [ ] Task 8: VPN with BGP
- [ ] Task 9: VPN Hub-and-Spoke

### Phase 2: Load Balancing
- [ ] Task 2: ALB with NGINX
- [ ] Task 5: NLB vs ALB
- [ ] Task 7: Full-Featured ALB

### Phase 3: Auto Scaling
- [ ] Task 3: Basic Autoscaling
- [ ] Task 10: Custom Metrics
- [ ] Task 11: Zero-Downtime Deployment

### Phase 4: Databases
- [ ] Task 12: MySQL RDS Tuning
- [ ] Task 13: Master-Slave Replication
- [ ] Task 14: Aurora

### Phase 5: Serverless
- [ ] Task 15: Event-Driven Microservice
- [ ] Task 16: Data Lake
- [ ] Task 22: API Gateway

### Phase 6: Compute
- [ ] Task 17: ML/Batch Cluster
- [ ] Task 18: Disk Management

### Phase 7: Security
- [ ] Task 19: Zero Trust & IAM

### Phase 8: Storage
- [ ] Task 20: S3 Replication

---

**Remember**: One task per day. Quality over speed! 🎯
