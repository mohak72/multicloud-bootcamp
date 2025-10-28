# Multi-Cloud Infrastructure Bootcamp Makefile
# Simplifies common operations across AWS and OCI

.PHONY: help init plan apply destroy clean test fmt validate docs

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "$(GREEN)Multi-Cloud Infrastructure Bootcamp - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Usage Examples:$(NC)"
	@echo "  make aws-init PROJECT=01-networking"
	@echo "  make aws-plan PROJECT=01-networking"
	@echo "  make oci-apply PROJECT=01-networking"
	@echo ""

# ============================================================================
# AWS Commands
# ============================================================================

aws-init: ## Initialize Terraform for AWS project (usage: make aws-init PROJECT=01-networking)
	@echo "$(GREEN)Initializing AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform init

aws-plan: ## Plan Terraform changes for AWS project
	@echo "$(GREEN)Planning AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform plan

aws-apply: ## Apply Terraform changes for AWS project
	@echo "$(YELLOW)Applying AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform apply

aws-destroy: ## Destroy AWS infrastructure
	@echo "$(RED)Destroying AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform destroy

aws-validate: ## Validate AWS Terraform configuration
	@echo "$(GREEN)Validating AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform validate

aws-fmt: ## Format AWS Terraform files
	@echo "$(GREEN)Formatting AWS project: $(PROJECT)$(NC)"
	@cd aws/$(PROJECT) && terraform fmt -recursive

# ============================================================================
# OCI Commands
# ============================================================================

oci-init: ## Initialize Terraform for OCI project
	@echo "$(GREEN)Initializing OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform init

oci-plan: ## Plan Terraform changes for OCI project
	@echo "$(GREEN)Planning OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform plan

oci-apply: ## Apply Terraform changes for OCI project
	@echo "$(YELLOW)Applying OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform apply

oci-destroy: ## Destroy OCI infrastructure
	@echo "$(RED)Destroying OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform destroy

oci-validate: ## Validate OCI Terraform configuration
	@echo "$(GREEN)Validating OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform validate

oci-fmt: ## Format OCI Terraform files
	@echo "$(GREEN)Formatting OCI project: $(PROJECT)$(NC)"
	@cd oci/$(PROJECT) && terraform fmt -recursive

# ============================================================================
# Global Commands
# ============================================================================

init-all: ## Initialize all Terraform projects
	@echo "$(GREEN)Initializing all AWS projects...$(NC)"
	@for dir in aws/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Initializing $$dir"; \
			cd $$dir && terraform init && cd ../..; \
		fi \
	done
	@echo "$(GREEN)Initializing all OCI projects...$(NC)"
	@for dir in oci/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Initializing $$dir"; \
			cd $$dir && terraform init && cd ../..; \
		fi \
	done

fmt-all: ## Format all Terraform files
	@echo "$(GREEN)Formatting all Terraform files...$(NC)"
	@terraform fmt -recursive aws/
	@terraform fmt -recursive oci/

validate-all: ## Validate all Terraform configurations
	@echo "$(GREEN)Validating all Terraform configurations...$(NC)"
	@for dir in aws/*/ oci/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Validating $$dir"; \
			cd $$dir && terraform validate && cd ../..; \
		fi \
	done

clean: ## Clean Terraform cache and state files (BE CAREFUL!)
	@echo "$(RED)Cleaning Terraform cache files...$(NC)"
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfstate*" -exec rm -f {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -exec rm -f {} + 2>/dev/null || true
	@echo "$(GREEN)Cleanup complete$(NC)"

# ============================================================================
# Security & Quality
# ============================================================================

security-scan: ## Run security scan with tfsec
	@echo "$(GREEN)Running security scan...$(NC)"
	@which tfsec > /dev/null || (echo "$(RED)tfsec not installed. Install: brew install tfsec$(NC)" && exit 1)
	@tfsec aws/
	@tfsec oci/

lint: ## Run Terraform linting
	@echo "$(GREEN)Running terraform linting...$(NC)"
	@which tflint > /dev/null || (echo "$(RED)tflint not installed. Install: brew install tflint$(NC)" && exit 1)
	@tflint aws/
	@tflint oci/

# ============================================================================
# Setup & Configuration
# ============================================================================

setup-aws: ## Setup AWS CLI credentials
	@echo "$(GREEN)Setting up AWS CLI...$(NC)"
	@aws configure

setup-oci: ## Setup OCI CLI configuration
	@echo "$(GREEN)Setting up OCI CLI...$(NC)"
	@oci setup config

check-tools: ## Check if required tools are installed
	@echo "$(GREEN)Checking required tools...$(NC)"
	@which terraform > /dev/null && echo "✓ Terraform installed" || echo "$(RED)✗ Terraform not installed$(NC)"
	@which aws > /dev/null && echo "✓ AWS CLI installed" || echo "$(RED)✗ AWS CLI not installed$(NC)"
	@which oci > /dev/null && echo "✓ OCI CLI installed" || echo "$(RED)✗ OCI CLI not installed$(NC)"
	@which git > /dev/null && echo "✓ Git installed" || echo "$(RED)✗ Git not installed$(NC)"
	@which tfsec > /dev/null && echo "✓ tfsec installed (optional)" || echo "$(YELLOW)⚠ tfsec not installed (optional)$(NC)"

# ============================================================================
# Git & GitHub
# ============================================================================

git-init: ## Initialize Git repository
	@echo "$(GREEN)Initializing Git repository...$(NC)"
	@git init
	@git add .
	@git commit -m "Initial commit: Multi-Cloud Bootcamp project structure"
	@echo "$(GREEN)Git repository initialized. Add remote with: git remote add origin <url>$(NC)"

# ============================================================================
# Documentation
# ============================================================================

docs: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(NC)"
	@which terraform-docs > /dev/null || (echo "$(RED)terraform-docs not installed$(NC)" && exit 1)
	@for dir in aws/*/ oci/*/; do \
		if [ -f "$$dir/main.tf" ]; then \
			echo "Generating docs for $$dir"; \
			terraform-docs markdown "$$dir" > "$$dir/README.md"; \
		fi \
	done

# ============================================================================
# Cost Estimation
# ============================================================================

cost-estimate: ## Estimate infrastructure costs (requires infracost)
	@echo "$(GREEN)Estimating costs for: $(PROJECT)$(NC)"
	@which infracost > /dev/null || (echo "$(RED)infracost not installed$(NC)" && exit 1)
	@cd aws/$(PROJECT) && infracost breakdown --path .

# ============================================================================
# Testing
# ============================================================================

test: ## Run Terraform tests
	@echo "$(GREEN)Running tests...$(NC)"
	@echo "Test framework coming soon..."
