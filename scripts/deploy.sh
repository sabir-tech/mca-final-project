#!/bin/bash

# =============================================================================
# Deployment Script for WordPress on GKE
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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI is not installed. Please install it from https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install it from https://www.terraform.io/downloads"
        exit 1
    fi
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed. Please install it from https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    
    log_success "All prerequisites are installed!"
}

# Initialize GCP project
init_gcp() {
    log_info "Checking GCP authentication..."
    
    # Check if authenticated with gcloud CLI
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 &> /dev/null; then
        log_warning "Not authenticated with GCP. Running 'gcloud auth login'..."
        gcloud auth login
    fi
    
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1)
    log_success "Authenticated as: $ACTIVE_ACCOUNT"
    
    # IMPORTANT: Terraform uses Application Default Credentials (ADC), not gcloud CLI auth
    # Check if ADC is configured
    log_info "Checking Application Default Credentials for Terraform..."
    
    if [ ! -f "$HOME/.config/gcloud/application_default_credentials.json" ]; then
        log_warning "Application Default Credentials not found!"
        log_info "Terraform requires ADC to authenticate with GCP APIs."
        log_info "Running 'gcloud auth application-default login'..."
        echo ""
        gcloud auth application-default login
    else
        log_success "Application Default Credentials found!"
    fi
    
    # Set the project for gcloud commands
    PROJECT_ID=$(grep -E "^project_id\s*=" ../terraform/terraform.tfvars 2>/dev/null | sed 's/.*=\s*"\(.*\)"/\1/' | tr -d ' ')
    if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "your-gcp-project-id" ]; then
        log_info "Setting GCP project to: $PROJECT_ID"
        gcloud config set project "$PROJECT_ID"
    fi
    
    # Enable required APIs
    log_info "Enabling required GCP APIs (this may take a minute)..."
    gcloud services enable compute.googleapis.com --quiet || true
    gcloud services enable container.googleapis.com --quiet || true
    gcloud services enable iam.googleapis.com --quiet || true
    gcloud services enable cloudresourcemanager.googleapis.com --quiet || true
    
    log_success "GCP authentication and APIs verified!"
}

# Deploy Terraform infrastructure
deploy_terraform() {
    log_info "Deploying Terraform infrastructure..."
    
    cd ../terraform
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        log_warning "terraform.tfvars not found. Copying from example..."
        cp terraform.tfvars.example terraform.tfvars
        log_warning "Please edit terraform.tfvars with your GCP project ID and run this script again."
        exit 1
    fi
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Validate Terraform configuration
    log_info "Validating Terraform configuration..."
    terraform validate
    
    # Plan Terraform changes
    log_info "Planning Terraform changes..."
    terraform plan -out=tfplan
    
    # Apply Terraform changes
    read -p "Do you want to apply these changes? (yes/no): " confirm
    if [ "$confirm" == "yes" ]; then
        log_info "Applying Terraform changes..."
        terraform apply tfplan
        log_success "Terraform infrastructure deployed successfully!"
    else
        log_warning "Terraform apply cancelled."
        exit 0
    fi
    
    cd ../scripts
}

# Configure kubectl
configure_kubectl() {
    log_info "Configuring kubectl..."
    
    cd ../terraform
    
    # Get the kubectl config command from Terraform output
    KUBECTL_CMD=$(terraform output -raw kubectl_config_command)
    
    log_info "Running: $KUBECTL_CMD"
    eval $KUBECTL_CMD
    
    # Verify kubectl configuration
    log_info "Verifying kubectl configuration..."
    kubectl cluster-info
    
    log_success "kubectl configured successfully!"
    
    cd ../scripts
}

# Deploy Kubernetes resources
deploy_kubernetes() {
    log_info "Deploying Kubernetes resources..."
    
    cd ../kubernetes
    
    # Create namespace
    log_info "Creating namespace..."
    kubectl apply -f namespace.yaml
    
    # Wait for namespace to be ready
    sleep 2
    
    # Create secrets and configmaps
    log_info "Creating secrets and configmaps..."
    kubectl apply -f secrets.yaml
    kubectl apply -f configmap.yaml
    
    # Deploy MySQL
    log_info "Deploying MySQL..."
    kubectl apply -f mysql/
    
    # Wait for MySQL to be ready
    log_info "Waiting for MySQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=mysql -n wordpress --timeout=300s
    
    # Deploy WordPress
    log_info "Deploying WordPress..."
    kubectl apply -f wordpress/
    
    # Wait for WordPress to be ready
    log_info "Waiting for WordPress pods to be ready..."
    kubectl wait --for=condition=ready pod -l app=wordpress -n wordpress --timeout=300s
    
    log_success "Kubernetes resources deployed successfully!"
    
    cd ../scripts
}

# Get application URL
get_app_url() {
    log_info "Getting WordPress LoadBalancer IP..."
    
    # Wait for LoadBalancer IP
    log_info "Waiting for LoadBalancer IP (this may take a few minutes)..."
    
    for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get svc wordpress-service -n wordpress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            break
        fi
        echo -n "."
        sleep 10
    done
    echo ""
    
    if [ -n "$EXTERNAL_IP" ]; then
        log_success "WordPress is accessible at: http://$EXTERNAL_IP"
        echo ""
        echo "=================================================="
        echo "  WordPress URL: http://$EXTERNAL_IP"
        echo "  Complete the WordPress installation wizard"
        echo "=================================================="
    else
        log_warning "LoadBalancer IP not yet assigned. Run 'kubectl get svc -n wordpress' to check status."
    fi
}

# Main deployment function
main() {
    echo ""
    echo "=================================================="
    echo "  WordPress on GKE - Deployment Script"
    echo "  MCA Final Project - Mohd Sabir"
    echo "=================================================="
    echo ""
    
    check_prerequisites
    init_gcp
    deploy_terraform
    configure_kubectl
    deploy_kubernetes
    get_app_url
    
    echo ""
    log_success "Deployment completed successfully!"
    echo ""
}

# Run main function
main "$@"

