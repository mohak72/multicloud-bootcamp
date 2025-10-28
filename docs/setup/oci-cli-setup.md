# OCI CLI Setup Guide

Complete guide for setting up Oracle Cloud Infrastructure (OCI) CLI for Terraform authentication.

## Table of Contents
1. [Install OCI CLI](#install-oci-cli)
2. [Configure OCI Credentials](#configure-oci-credentials)
3. [Get Required OCIDs](#get-required-ocids)
4. [Test Configuration](#test-configuration)
5. [Setup for Terraform](#setup-for-terraform)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## 1. Install OCI CLI

### Windows (Git Bash/MinGW/PowerShell)

```powershell
# PowerShell (Run as Administrator)
Set-ExecutionPolicy RemoteSigned

# Install OCI CLI
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.ps1'))"

# Verify installation
oci --version
```

### macOS

```bash
# Using Homebrew
brew update && brew install oci-cli

# Verify installation
oci --version
```

### Linux

```bash
# Using installer script
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Add to PATH (if not already)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
oci --version
```

---

## 2. Configure OCI Credentials

### Interactive Setup (Recommended)

```bash
# Run OCI setup
oci setup config

# You'll be prompted for:
# - Config file location: ~/.oci/config
# - User OCID
# - Tenancy OCID
# - Region (e.g., us-ashburn-1)
# - Generate RSA key pair: Y
```

This will create:
- `~/.oci/config` - Configuration file
- `~/.oci/oci_api_key.pem` - Private key
- `~/.oci/oci_api_key_public.pem` - Public key

### Manual Setup

```bash
# Create OCI directory
mkdir -p ~/.oci

# Create config file
nano ~/.oci/config
```

Add the following content:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
tenancy=ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
region=us-ashburn-1
key_file=~/.oci/oci_api_key.pem

[DEV]
user=ocid1.user.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint=yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy:yy
tenancy=ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
region=us-ashburn-1
key_file=~/.oci/oci_api_key_dev.pem

[PROD]
user=ocid1.user.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint=zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz:zz
tenancy=ocid1.tenancy.oc1..aaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
region=us-phoenix-1
key_file=~/.oci/oci_api_key_prod.pem
```

### Generate API Keys Manually

```bash
# Generate private key
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# Set permissions
chmod 600 ~/.oci/oci_api_key.pem

# Generate public key
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

# Display public key (for uploading to OCI)
cat ~/.oci/oci_api_key_public.pem
```

---

## 3. Get Required OCIDs

### A. Upload Public Key to OCI Console

1. **Login to OCI Console**: https://cloud.oracle.com/
2. **Navigate to User Settings**:
   - Click Profile Icon (top right)
   - Click "User Settings"
3. **Add API Key**:
   - Click "API Keys" (left menu)
   - Click "Add API Key"
   - Select "Paste Public Key"
   - Paste content of `~/.oci/oci_api_key_public.pem`
   - Click "Add"
4. **Copy Configuration**:
   - After adding, OCI shows a preview of config
   - Copy the fingerprint value

### B. Get Tenancy OCID

```bash
# Method 1: From OCI Console
# Profile Icon → Tenancy → Copy OCID

# Method 2: From CLI (after setup)
oci iam tenancy get --tenancy-id $(grep tenancy ~/.oci/config | cut -d'=' -f2)
```

### C. Get User OCID

```bash
# From OCI Console
# Profile Icon → User Settings → Copy OCID
```

### D. Get Compartment OCID

```bash
# List all compartments
oci iam compartment list --all

# Create new compartment (optional)
oci iam compartment create \
  --compartment-id <parent-compartment-ocid> \
  --name "multicloud-bootcamp" \
  --description "Multi-cloud bootcamp resources"

# Use root compartment OCID (same as tenancy OCID for most cases)
```

### E. Choose Region

Common OCI Regions:
- `us-ashburn-1` (US East - Ashburn, VA)
- `us-phoenix-1` (US West - Phoenix, AZ)
- `eu-frankfurt-1` (Germany)
- `ap-mumbai-1` (India)
- `ap-tokyo-1` (Japan)

List all regions:
```bash
oci iam region list --output table
```

---

## 4. Test Configuration

```bash
# Test OCI CLI
oci iam user get --user-id <your-user-ocid>

# List availability domains
oci iam availability-domain list

# List VCNs (should return empty if none exist)
oci network vcn list --compartment-id <your-compartment-ocid>

# List compute instances
oci compute instance list --compartment-id <your-compartment-ocid>

# Verify configuration
oci setup repair-file-permissions --file ~/.oci/config
```

Expected output format:
```json
{
  "data": {
    "id": "ocid1.user.oc1..aaa...",
    "compartment-id": "ocid1.tenancy.oc1..aaa...",
    "name": "your-email@example.com",
    "lifecycle-state": "ACTIVE"
  }
}
```

---

## 5. Setup for Terraform

### A. Create terraform.tfvars

```bash
cd oci/01-networking
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Update with your values:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaxxxxxx"
user_ocid        = "ocid1.user.oc1..aaaaaaaxxxxxx"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "~/.oci/oci_api_key.pem"
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaxxxxxx"
region           = "us-ashburn-1"
```

### B. Test Terraform Authentication

```bash
cd oci/01-networking

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan (this will test OCI authentication)
terraform plan
```

---

## 6. Best Practices

### ✅ Security Best Practices

1. **Protect Private Keys**:
   ```bash
   # Set correct permissions
   chmod 600 ~/.oci/oci_api_key.pem
   chmod 644 ~/.oci/oci_api_key_public.pem
   chmod 600 ~/.oci/config

   # Verify permissions
   ls -la ~/.oci/
   ```

2. **Never Commit Credentials**:
   ```bash
   # Already in .gitignore
   ~/.oci/
   *.pem
   *.key
   terraform.tfvars
   ```

3. **Use Separate Keys for Environments**:
   - `oci_api_key_dev.pem` for development
   - `oci_api_key_prod.pem` for production

4. **Rotate API Keys Regularly**:
   ```bash
   # Generate new key pair
   openssl genrsa -out ~/.oci/oci_api_key_new.pem 2048
   openssl rsa -pubout -in ~/.oci/oci_api_key_new.pem -out ~/.oci/oci_api_key_new_public.pem

   # Upload new public key to OCI Console
   # Update config file with new fingerprint
   # Delete old key from OCI Console
   ```

5. **Use Instance Principal for Compute**:
   ```hcl
   provider "oci" {
     auth = "InstancePrincipal"
     region = var.region
   }
   ```

### ✅ Cost Management

1. **OCI Free Tier Benefits**:
   - 2 Always Free VMs (AMD E2.1 Micro)
   - 2 Block Volumes (100 GB total)
   - 10 GB Object Storage
   - VCN and Load Balancers (Always Free!)

2. **Set Budget Alerts**:
   - OCI Console → Billing → Budgets
   - Set alerts at 50%, 75%, 100% of budget

3. **Tag Resources**:
   ```hcl
   freeform_tags = {
     Environment = "dev"
     ManagedBy   = "Terraform"
     CostCenter  = "learning"
   }
   ```

---

## 7. Troubleshooting

### Issue: "Service error:NotAuthenticated"

```bash
# Check config file
cat ~/.oci/config

# Verify fingerprint matches uploaded key
oci setup repair-file-permissions --file ~/.oci/config

# Re-upload public key to OCI Console
cat ~/.oci/oci_api_key_public.pem
```

### Issue: "Private key file not found"

```bash
# Check if private key exists
ls -la ~/.oci/oci_api_key.pem

# Verify path in config
grep key_file ~/.oci/config

# Check permissions
chmod 600 ~/.oci/oci_api_key.pem
```

### Issue: "Invalid fingerprint"

```bash
# Get fingerprint from private key
openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c

# Compare with OCI Console
# Profile → User Settings → API Keys → Check fingerprint
```

### Issue: "Compartment not found"

```bash
# List all compartments
oci iam compartment list --all --compartment-id-in-subtree true

# Use tenancy OCID as compartment OCID (root compartment)
grep tenancy ~/.oci/config
```

### Issue: "Region not found"

```bash
# List available regions
oci iam region list

# Subscribe to region
# OCI Console → Manage Regions → Subscribe
```

---

## Quick Reference

### Common OCI CLI Commands

```bash
# List VCNs
oci network vcn list --compartment-id <compartment-ocid>

# List subnets
oci network subnet list --compartment-id <compartment-ocid>

# List compute instances
oci compute instance list --compartment-id <compartment-ocid>

# List availability domains
oci iam availability-domain list

# List shapes (instance types)
oci compute shape list --compartment-id <compartment-ocid>

# List images
oci compute image list --compartment-id <compartment-ocid>

# Get user info
oci iam user get --user-id <user-ocid>

# Switch profiles
export OCI_CLI_PROFILE=DEV
```

### Useful Environment Variables

```bash
# Set OCI profile
export OCI_CLI_PROFILE=PROD

# Set compartment
export OCI_CLI_COMPARTMENT_ID=ocid1.compartment.oc1..aaa...

# Set region
export OCI_CLI_REGION=us-phoenix-1
```

### Understanding OCIDs

Format: `ocid1.<resource-type>.<realm>.<region>.<unique-id>`

Examples:
```
ocid1.user.oc1..aaaaaaaxxxxx           # User OCID
ocid1.tenancy.oc1..aaaaaaaxxxxx        # Tenancy OCID
ocid1.compartment.oc1..aaaaaaaxxxxx    # Compartment OCID
ocid1.vcn.oc1.iad.aaaaaaaxxxxx         # VCN OCID (in us-ashburn-1)
```

---

## Next Steps

1. ✅ OCI CLI installed and configured
2. ✅ API keys generated and uploaded
3. ✅ Credentials tested and working
4. ➡️ Proceed to: [Terraform Setup](./terraform-setup.md)
5. ➡️ Start with: [Task 1 - Networking](../../oci/01-networking/README.md)

---

## Additional Resources

- [OCI CLI Documentation](https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/)
- [OCI SDK and CLI Configuration](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm)
- [OCI Free Tier](https://www.oracle.com/cloud/free/)
- [OCI Regions and Availability Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
