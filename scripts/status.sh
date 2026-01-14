#!/bin/bash

# =============================================================================
# Status Script for WordPress on GKE
# MCA Final Project - Mohd Sabir
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check cluster status
check_cluster() {
    print_header "GKE Cluster Status"
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        log_info "Run 'gcloud container clusters get-credentials <cluster-name> --region <region>' to configure kubectl"
        return 1
    fi
    
    kubectl cluster-info
    echo ""
}

# Check namespace
check_namespace() {
    print_header "Namespace Status"
    
    if kubectl get namespace wordpress &> /dev/null; then
        log_success "Namespace 'wordpress' exists"
    else
        log_error "Namespace 'wordpress' does not exist"
        return 1
    fi
    echo ""
}

# Check pods
check_pods() {
    print_header "Pod Status"
    kubectl get pods -n wordpress -o wide
    echo ""
    
    # Check for any unhealthy pods
    UNHEALTHY=$(kubectl get pods -n wordpress --field-selector=status.phase!=Running,status.phase!=Succeeded -o name 2>/dev/null)
    if [ -n "$UNHEALTHY" ]; then
        log_warning "Unhealthy pods detected:"
        echo "$UNHEALTHY"
    fi
    echo ""
}

# Check services
check_services() {
    print_header "Service Status"
    kubectl get svc -n wordpress
    echo ""
    
    # Get WordPress LoadBalancer IP
    EXTERNAL_IP=$(kubectl get svc wordpress-service -n wordpress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$EXTERNAL_IP" ]; then
        log_success "WordPress URL: http://$EXTERNAL_IP"
    else
        log_warning "WordPress LoadBalancer IP is not yet assigned"
    fi
    echo ""
}

# Check persistent volumes
check_storage() {
    print_header "Storage Status"
    kubectl get pvc -n wordpress
    echo ""
    kubectl get pv 2>/dev/null | grep wordpress || true
    echo ""
}

# Check deployments
check_deployments() {
    print_header "Deployment Status"
    kubectl get deployments -n wordpress
    echo ""
}

# Check HPA
check_hpa() {
    print_header "Horizontal Pod Autoscaler Status"
    kubectl get hpa -n wordpress 2>/dev/null || log_info "No HPA configured"
    echo ""
}

# Check recent events
check_events() {
    print_header "Recent Events (last 10)"
    kubectl get events -n wordpress --sort-by='.lastTimestamp' | tail -10
    echo ""
}

# Check resource usage
check_resources() {
    print_header "Resource Usage"
    if kubectl top nodes &> /dev/null; then
        echo "Node Resources:"
        kubectl top nodes
        echo ""
        echo "Pod Resources:"
        kubectl top pods -n wordpress 2>/dev/null || log_info "Metrics server may not be ready"
    else
        log_warning "Metrics server is not available"
    fi
    echo ""
}

# Main function
main() {
    echo ""
    echo "=================================================="
    echo "  WordPress on GKE - Status Dashboard"
    echo "  MCA Final Project - Mohd Sabir"
    echo "  $(date)"
    echo "=================================================="
    echo ""
    
    check_cluster || exit 1
    check_namespace || exit 1
    check_pods
    check_services
    check_storage
    check_deployments
    check_hpa
    check_events
    check_resources
    
    echo ""
    log_success "Status check completed!"
    echo ""
}

# Run main function
main "$@"

