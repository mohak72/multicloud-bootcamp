# Self-Hosted GitHub Actions Runners Setup

Complete guide for setting up self-hosted GitHub Actions runners locally and in the cloud.

## Table of Contents
1. [Why Self-Hosted Runners?](#why-self-hosted-runners)
2. [Local Runner Setup](#local-runner-setup)
3. [Cloud Runner Setup](#cloud-runner-setup)
4. [Security Considerations](#security-considerations)
5. [Runner Management](#runner-management)
6. [Troubleshooting](#troubleshooting)

---

## Why Self-Hosted Runners?

### Advantages ✅
- **Cost Savings**: No GitHub Actions minutes usage
- **Performance**: Faster builds with more resources
- **Access**: Direct access to local resources/network
- **Customization**: Install any tools/dependencies
- **Learning**: Great for development/testing

### Disadvantages ❌
- **Maintenance**: You manage updates/security
- **Availability**: Must be running 24/7 for production
- **Security**: More attack surface
- **Scaling**: Manual scaling vs cloud auto-scaling

### When to Use
- ✅ **Development/Learning**: Perfect for bootcamp
- ✅ **Cost Optimization**: High workflow usage
- ✅ **Special Requirements**: Custom tools/hardware
- ❌ **Production**: Use cloud runners unless necessary
- ❌ **Public Repos**: Security risk with self-hosted

---

## Local Runner Setup

### Option 1: Windows (Native)

#### Prerequisites
```powershell
# Check Windows version (Windows 10/11 or Windows Server 2019+)
winver

# Install Git
winget install Git.Git

# Install PowerShell 7+
winget install Microsoft.PowerShell
```

#### Setup Steps

1. **Get Runner Token from GitHub**:
   ```
   GitHub Repo → Settings → Actions → Runners → New self-hosted runner
   ```

2. **Download Runner**:
   ```powershell
   # Create directory
   mkdir C:\actions-runner
   cd C:\actions-runner

   # Download latest runner
   Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-win-x64-2.311.0.zip -OutFile actions-runner-win-x64-2.311.0.zip

   # Extract
   Expand-Archive -Path actions-runner-win-x64-2.311.0.zip -DestinationPath .
   ```

3. **Configure Runner**:
   ```powershell
   # Configure
   .\config.cmd --url https://github.com/YOUR-USERNAME/multicloud-bootcamp --token YOUR-TOKEN

   # Answer prompts:
   # Runner group: Default
   # Runner name: local-windows-runner
   # Work folder: _work
   # Run as service: N (for now)
   ```

4. **Run Runner**:
   ```powershell
   # Run interactively (for testing)
   .\run.cmd

   # Or install as Windows Service (recommended)
   .\svc.cmd install
   .\svc.cmd start
   ```

#### Install Dependencies on Windows Runner

```powershell
# Install Terraform
winget install Hashicorp.Terraform

# Install AWS CLI
winget install Amazon.AWSCLI

# Install OCI CLI (use installer from Oracle)
# Download from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/climanualinstall.htm

# Verify installations
terraform --version
aws --version
oci --version
```

---

### Option 2: Linux/WSL/Git Bash

#### Prerequisites
```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl git jq
```

#### Setup Steps

1. **Get Runner Token** from GitHub (same as Windows)

2. **Download and Configure**:
   ```bash
   # Create directory
   mkdir -p ~/actions-runner && cd ~/actions-runner

   # Download latest runner
   curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

   # Extract
   tar xzf actions-runner-linux-x64-2.311.0.tar.gz

   # Configure
   ./config.sh --url https://github.com/YOUR-USERNAME/multicloud-bootcamp --token YOUR-TOKEN

   # Answer prompts:
   # Runner group: Default
   # Runner name: local-linux-runner
   # Work folder: _work
   ```

3. **Run Runner**:
   ```bash
   # Run interactively (for testing)
   ./run.sh

   # Or install as systemd service (recommended)
   sudo ./svc.sh install
   sudo ./svc.sh start
   sudo ./svc.sh status
   ```

#### Install Dependencies on Linux Runner

```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Verify installations
terraform --version
aws --version
oci --version
```

---

### Option 3: Docker Runner (Advanced)

```bash
# Pull GitHub Actions runner image
docker pull myoung34/github-runner:latest

# Run runner container
docker run -d --restart always \
  --name github-runner \
  -e RUNNER_NAME="docker-runner" \
  -e RUNNER_WORK_DIRECTORY="/tmp/runner" \
  -e RUNNER_TOKEN="YOUR-TOKEN" \
  -e REPO_URL="https://github.com/YOUR-USERNAME/multicloud-bootcamp" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  myoung34/github-runner:latest
```

---

## Cloud Runner Setup

### AWS EC2 Runner

#### Launch EC2 Instance

```bash
# Using AWS CLI
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.small \
  --key-name your-key-pair \
  --security-group-ids sg-xxxxxxxxx \
  --subnet-id subnet-xxxxxxxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=github-runner}]' \
  --user-data file://runner-setup.sh
```

#### runner-setup.sh (User Data Script)

```bash
#!/bin/bash

# Update system
yum update -y

# Install dependencies
yum install -y git curl jq docker

# Start Docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
mv terraform /usr/local/bin/

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Setup GitHub Actions Runner
cd /home/ec2-user
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
tar xzf actions-runner-linux-x64-2.311.0.tar.gz

# Configure runner (need to get token from GitHub)
# ./config.sh --url https://github.com/YOUR-USERNAME/multicloud-bootcamp --token YOUR-TOKEN

# Install as service
# sudo ./svc.sh install
# sudo ./svc.sh start
```

---

### OCI Compute Instance Runner

#### Launch Instance

```bash
# Using OCI CLI
oci compute instance launch \
  --availability-domain "US-ASHBURN-AD-1" \
  --compartment-id "ocid1.compartment.oc1..aaa..." \
  --shape "VM.Standard.E2.1.Micro" \
  --image-id "ocid1.image.oc1.iad.aaa..." \
  --subnet-id "ocid1.subnet.oc1.iad.aaa..." \
  --display-name "github-runner" \
  --assign-public-ip true \
  --ssh-authorized-keys-file ~/.ssh/id_rsa.pub \
  --user-data-file runner-setup.sh
```

---

## Security Considerations

### ⚠️ Critical Security Warnings

1. **Never use self-hosted runners for public repositories**
   - Anyone can submit PR with malicious code
   - Code runs on your infrastructure

2. **Isolate Runners**:
   ```yaml
   # In workflow file
   runs-on: self-hosted
   # Only allow trusted branches
   if: github.ref == 'refs/heads/main'
   ```

3. **Use Separate Runners for Prod**:
   ```yaml
   jobs:
     deploy-dev:
       runs-on: self-hosted-dev
     deploy-prod:
       runs-on: self-hosted-prod
   ```

4. **Secure Credentials**:
   ```bash
   # Use GitHub Secrets, not environment variables
   # aws/01-networking/terraform.tfvars should be in .gitignore
   ```

5. **Firewall Rules**:
   ```bash
   # Allow only necessary outbound traffic
   # Block inbound except SSH from your IP
   ```

6. **Regular Updates**:
   ```bash
   # Update runner regularly
   cd ~/actions-runner
   ./config.sh remove --token YOUR-TOKEN
   # Download latest version
   ./config.sh --url ... --token YOUR-TOKEN
   ```

---

## Runner Management

### Check Runner Status

```bash
# On runner machine
sudo ./svc.sh status

# Or check in GitHub
# Repository → Settings → Actions → Runners
```

### Stop Runner

```bash
# Stop service
sudo ./svc.sh stop

# Remove runner
./config.sh remove --token YOUR-TOKEN
```

### Restart Runner

```bash
# Restart service
sudo ./svc.sh restart

# Or stop and start
sudo ./svc.sh stop
sudo ./svc.sh start
```

### View Logs

```bash
# Linux systemd logs
sudo journalctl -u actions.runner.* -f

# Windows Event Viewer
# Open Event Viewer → Applications and Services Logs → GitHub Runner
```

---

## Using Self-Hosted Runners in Workflows

### Update Workflow Files

```yaml
# Change this:
runs-on: ubuntu-latest

# To this:
runs-on: self-hosted

# Or use labels:
runs-on: [self-hosted, linux, x64]
```

### Example with Labels

```yaml
jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: [self-hosted, terraform, aws]  # Match your runner labels

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Terraform Plan
        run: |
          cd aws/01-networking
          terraform init
          terraform plan
```

---

## Troubleshooting

### Issue: Runner not connecting

```bash
# Check network connectivity
ping github.com

# Check runner status
sudo ./svc.sh status

# Check logs
sudo journalctl -u actions.runner.* -f
```

### Issue: Permission denied

```bash
# Fix file permissions
chmod +x run.sh
chmod +x config.sh

# Fix work directory permissions
sudo chown -R $USER:$USER _work/
```

### Issue: Terraform not found

```bash
# Add Terraform to PATH
export PATH="$PATH:/usr/local/bin"

# Or install in runner directory
cd ~/actions-runner
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
chmod +x terraform
```

### Issue: AWS credentials not found

```bash
# Configure AWS CLI for runner user
su - ec2-user
aws configure

# Or use IAM role for EC2 instance (recommended)
```

---

## Recommendations

### For This Bootcamp

**Option 1: Local Runner (Best for Learning)**
```
✅ Free
✅ Fast iteration
✅ Direct access to your machine
✅ Easy to debug
❌ Must keep computer on
```

**Option 2: Cloud Runner (Best for Production)**
```
✅ Always available
✅ Scalable
✅ Professional setup
❌ Costs money (~$10-15/month)
```

**Recommendation**: Start with **local runner** for learning, move to cloud runner if you want 24/7 availability.

---

## Next Steps

1. ✅ Choose runner type (local or cloud)
2. ✅ Set up runner following guide above
3. ✅ Configure runner labels
4. ✅ Update workflow files to use self-hosted
5. ➡️ Test with: [Task 1 - Networking](../../aws/01-networking/README.md)

---

## Additional Resources

- [GitHub Self-Hosted Runners Docs](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Runner Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Actions Runner Controller (Kubernetes)](https://github.com/actions/actions-runner-controller)
