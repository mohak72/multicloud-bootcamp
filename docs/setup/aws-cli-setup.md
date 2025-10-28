# AWS CLI Setup Guide

Complete guide for setting up AWS CLI for Terraform authentication.

## Table of Contents
1. [Install AWS CLI](#install-aws-cli)
2. [Configure AWS Credentials](#configure-aws-credentials)
3. [Test Configuration](#test-configuration)
4. [Setup for Terraform](#setup-for-terraform)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## 1. Install AWS CLI

### Windows (Git Bash/MinGW)

```bash
# Download AWS CLI installer
curl "https://awscli.amazonaws.com/AWSCLIV2.msi" -o "AWSCLIV2.msi"

# Install (run in PowerShell as Administrator)
msiexec.exe /i AWSCLIV2.msi

# Verify installation
aws --version
```

### macOS

```bash
# Using Homebrew
brew install awscli

# Verify installation
aws --version
```

### Linux

```bash
# Download installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

---

## 2. Configure AWS Credentials

### Method 1: AWS Configure (Recommended for Beginners)

```bash
# Interactive configuration
aws configure

# You'll be prompted for:
# AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
# AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
# Default region name: us-east-1
# Default output format: json
```

### Method 2: Manual Configuration

```bash
# Create credentials file
mkdir -p ~/.aws

# Edit credentials
nano ~/.aws/credentials
```

Add the following content:

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY

[dev]
aws_access_key_id = YOUR_DEV_ACCESS_KEY_ID
aws_secret_access_key = YOUR_DEV_SECRET_ACCESS_KEY

[prod]
aws_access_key_id = YOUR_PROD_ACCESS_KEY_ID
aws_secret_access_key = YOUR_PROD_SECRET_ACCESS_KEY
```

Edit config file:

```bash
nano ~/.aws/config
```

Add the following content:

```ini
[default]
region = us-east-1
output = json

[profile dev]
region = us-east-1
output = json

[profile prod]
region = us-west-2
output = json
```

---

## 3. Get AWS Credentials

### Option A: IAM User (Recommended for Learning)

1. **Login to AWS Console**: https://console.aws.amazon.com/
2. **Navigate to IAM**: Services → IAM → Users
3. **Create User**:
   - Click "Add users"
   - Username: `terraform-user`
   - Access type: ✅ Programmatic access
4. **Attach Policies**:
   - For learning: `AdministratorAccess` (full access)
   - For production: Use least privilege policies
5. **Download Credentials**:
   - Save Access Key ID
   - Save Secret Access Key
   - ⚠️ This is the ONLY time you'll see the secret key!

### Option B: AWS SSO (For Organizations)

```bash
# Configure SSO
aws configure sso

# Follow prompts
SSO start URL: https://your-org.awsapps.com/start
SSO region: us-east-1
```

---

## 4. Test Configuration

```bash
# Test AWS CLI
aws sts get-caller-identity

# Expected output:
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}

# List S3 buckets (to verify permissions)
aws s3 ls

# Get current region
aws configure get region
```

---

## 5. Setup for Terraform

### Verify Terraform Can Use AWS Credentials

```bash
# Navigate to project
cd aws/01-networking

# Initialize Terraform
terraform init

# Plan (this will test AWS authentication)
terraform plan
```

### Using Different AWS Profiles

```bash
# Set profile via environment variable
export AWS_PROFILE=dev

# Or specify in Terraform
terraform plan -var="aws_profile=dev"
```

### Using AWS Profiles in Terraform

Edit `provider.tf`:

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "dev"  # Use specific profile
}
```

---

## 6. Best Practices

### ✅ Security Best Practices

1. **Never Commit Credentials**:
   ```bash
   # Already in .gitignore
   ~/.aws/credentials
   ~/.aws/config
   *.pem
   *.key
   ```

2. **Use IAM Roles for EC2/Lambda**:
   - Avoid storing credentials on instances
   - Use instance profiles instead

3. **Rotate Access Keys Regularly**:
   ```bash
   # Create new access key
   aws iam create-access-key --user-name terraform-user

   # Delete old access key
   aws iam delete-access-key --access-key-id OLD_KEY_ID --user-name terraform-user
   ```

4. **Enable MFA for IAM Users**:
   - AWS Console → IAM → Users → Security credentials → Assign MFA

5. **Use Least Privilege**:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ec2:*",
           "vpc:*",
           "s3:*"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

### ✅ Cost Management

1. **Set Billing Alerts**:
   - AWS Console → Billing → Budgets
   - Create alert for $10, $50, $100

2. **Tag All Resources**:
   ```hcl
   default_tags {
     tags = {
       Environment = "dev"
       ManagedBy   = "Terraform"
       CostCenter  = "learning"
     }
   }
   ```

---

## 7. Troubleshooting

### Issue: "Unable to locate credentials"

```bash
# Check if credentials file exists
cat ~/.aws/credentials

# Check environment variables
env | grep AWS

# Unset conflicting environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
```

### Issue: "Access Denied"

```bash
# Check IAM permissions
aws iam get-user

# Check which user you're authenticated as
aws sts get-caller-identity

# Verify region
aws configure get region
```

### Issue: "Invalid credentials"

```bash
# Re-configure AWS CLI
aws configure

# Or edit credentials directly
nano ~/.aws/credentials
```

### Issue: "Region not set"

```bash
# Set default region
aws configure set region us-east-1

# Or use environment variable
export AWS_DEFAULT_REGION=us-east-1
```

---

## Quick Reference

### Common AWS CLI Commands

```bash
# List all regions
aws ec2 describe-regions --output table

# List all VPCs
aws ec2 describe-vpcs

# List all EC2 instances
aws ec2 describe-instances

# List all S3 buckets
aws s3 ls

# Get current account info
aws sts get-caller-identity

# Switch profiles
export AWS_PROFILE=prod

# Use specific region
aws ec2 describe-instances --region us-west-2
```

### Useful Environment Variables

```bash
# Set AWS profile
export AWS_PROFILE=dev

# Set AWS region
export AWS_DEFAULT_REGION=us-east-1

# Set AWS output format
export AWS_DEFAULT_OUTPUT=json

# Enable AWS CLI debug mode
export AWS_DEBUG=true
```

---

## Next Steps

1. ✅ AWS CLI installed and configured
2. ✅ Credentials tested and working
3. ➡️ Proceed to: [Terraform Setup](./terraform-setup.md)
4. ➡️ Start with: [Task 1 - Networking](../../aws/01-networking/README.md)

---

## Additional Resources

- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Pricing Calculator](https://calculator.aws/)
