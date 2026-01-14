#!/bin/bash

# =============================================================================
# Validation Script for WordPress on GKE
# MCA Final Project - Mohd Sabir
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate Terraform configuration
validate_terraform() {
    log_info "Validating Terraform configuration..."
    
    cd ../terraform
    
    # Format check
    log_info "Checking Terraform formatting..."
    if terraform fmt -check -recursive; then
        log_success "Terraform formatting is correct!"
    else
        log_warning "Some Terraform files need formatting. Run 'terraform fmt -recursive'"
    fi
    
    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        log_info "Initializing Terraform..."
        terraform init
    fi
    
    # Validate configuration
    log_info "Validating Terraform syntax..."
    if terraform validate; then
        log_success "Terraform configuration is valid!"
    else
        log_error "Terraform validation failed!"
        exit 1
    fi
    
    cd ../scripts
}

# Validate Kubernetes manifests
validate_kubernetes() {
    log_info "Validating Kubernetes manifests..."
    
    cd ../kubernetes
    
    # Validate YAML syntax
    for file in $(find . -name "*.yaml" -type f); do
        log_info "Validating $file..."
        if kubectl apply --dry-run=client -f "$file" &> /dev/null; then
            log_success "$file is valid!"
        else
            log_error "$file has syntax errors!"
            kubectl apply --dry-run=client -f "$file"
        fi
    done
    
    cd ../scripts
}

# Check deployment status
check_deployment_status() {
    log_info "Checking deployment status..."
    
    # Check if kubectl is configured
    if ! kubectl cluster-info &> /dev/null; then
        log_warning "kubectl is not configured. Skipping deployment status check."
        return
    fi
    
    # Check namespace
    if kubectl get namespace wordpress &> /dev/null; then
        log_success "Namespace 'wordpress' exists"
        
        # Check pods
        log_info "Checking pods..."
        kubectl get pods -n wordpress -o wide
        
        # Check services
        log_info "Checking services..."
        kubectl get svc -n wordpress
        
        # Check PVCs
        log_info "Checking persistent volume claims..."
        kubectl get pvc -n wordpress
        
        # Check secrets
        log_info "Checking secrets..."
        kubectl get secrets -n wordpress
        
        # Check deployments
        log_info "Checking deployments..."
        kubectl get deployments -n wordpress
        
    else
        log_warning "Namespace 'wordpress' does not exist. Application may not be deployed."
    fi
}

# Main validation function
main() {
    echo ""
    echo "=================================================="
    echo "  WordPress on GKE - Validation Script"
    echo "  MCA Final Project - Mohd Sabir"
    echo "=================================================="
    echo ""
    
    validate_terraform
    validate_kubernetes
    check_deployment_status
    
    echo ""
    log_success "Validation completed!"
    echo ""
}

# Run main function
main "$@"

