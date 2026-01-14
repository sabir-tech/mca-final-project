#!/bin/bash

# =============================================================================
# Destroy Script for WordPress on GKE
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

# Destroy Kubernetes resources
destroy_kubernetes() {
    log_info "Destroying Kubernetes resources..."
    
    cd ../kubernetes
    
    # Check if kubectl is configured
    if ! kubectl cluster-info &> /dev/null; then
        log_warning "kubectl is not configured. Skipping Kubernetes resource deletion."
        cd ../scripts
        return
    fi
    
    # Check if namespace exists
    if kubectl get namespace wordpress &> /dev/null; then
        # Delete WordPress resources
        log_info "Deleting WordPress resources..."
        kubectl delete -f wordpress/ --ignore-not-found=true || true
        
        # Delete MySQL resources
        log_info "Deleting MySQL resources..."
        kubectl delete -f mysql/ --ignore-not-found=true || true
        
        # Delete secrets and configmaps
        log_info "Deleting secrets and configmaps..."
        kubectl delete -f secrets.yaml --ignore-not-found=true || true
        kubectl delete -f configmap.yaml --ignore-not-found=true || true
        
        # Delete namespace
        log_info "Deleting namespace..."
        kubectl delete -f namespace.yaml --ignore-not-found=true || true
        
        log_success "Kubernetes resources deleted!"
    else
        log_warning "WordPress namespace not found. Skipping Kubernetes resource deletion."
    fi
    
    cd ../scripts
}

# Destroy Terraform infrastructure
destroy_terraform() {
    log_info "Destroying Terraform infrastructure..."
    
    cd ../terraform
    
    # Check if terraform state exists
    if [ ! -f "terraform.tfstate" ]; then
        log_warning "No Terraform state found. Nothing to destroy."
        cd ../scripts
        return
    fi
    
    # Plan Terraform destroy
    log_info "Planning Terraform destroy..."
    terraform plan -destroy -out=destroy-plan
    
    # Confirm destruction
    echo ""
    log_warning "WARNING: This will destroy ALL infrastructure resources!"
    log_warning "This action cannot be undone!"
    echo ""
    
    read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        log_info "Destroying Terraform infrastructure..."
        terraform apply destroy-plan
        log_success "Terraform infrastructure destroyed!"
    else
        log_warning "Terraform destroy cancelled."
    fi
    
    # Clean up plan files
    rm -f tfplan destroy-plan
    
    cd ../scripts
}

# Main destroy function
main() {
    echo ""
    echo "=================================================="
    echo "  WordPress on GKE - Destroy Script"
    echo "  MCA Final Project - Mohd Sabir"
    echo "=================================================="
    echo ""
    
    log_warning "This script will destroy all deployed resources."
    echo ""
    
    read -p "Do you want to continue? (yes/no): " initial_confirm
    if [ "$initial_confirm" != "yes" ]; then
        log_info "Destroy operation cancelled."
        exit 0
    fi
    
    destroy_kubernetes
    destroy_terraform
    
    echo ""
    log_success "All resources have been destroyed!"
    echo ""
}

# Run main function
main "$@"

