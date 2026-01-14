# Deployment Guide

## Step-by-Step Deployment Instructions

This guide provides detailed instructions for deploying the WordPress application on GKE.

## Prerequisites Setup

### 1. Install Required Tools

#### Google Cloud SDK

```bash
# macOS (using Homebrew)
brew install google-cloud-sdk

# Linux
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
tar -xf google-cloud-cli-linux-x86_64.tar.gz
./google-cloud-sdk/install.sh

# Windows
# Download installer from: https://cloud.google.com/sdk/docs/install
```

#### Terraform

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

#### kubectl

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### 2. GCP Project Setup

```bash
# Login to GCP
gcloud auth login

# Create a new project (optional)
gcloud projects create YOUR_PROJECT_ID --name="WordPress GKE Project"

# Set the project
gcloud config set project YOUR_PROJECT_ID

# Link billing account
gcloud billing projects link YOUR_PROJECT_ID --billing-account=BILLING_ACCOUNT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

## Deployment Steps

### Step 1: Configure Terraform Variables

```bash
cd terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit the file with your values
nano terraform.tfvars
```

**Required changes in terraform.tfvars:**

```hcl
# MUST CHANGE
project_id = "your-actual-gcp-project-id"

# OPTIONAL - Customize as needed
region = "us-central1"
environment = "dev"
node_count = 2
```

### Step 2: Deploy Infrastructure with Terraform

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes (type 'yes' when prompted)
terraform apply
```

**Expected output:**

```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

cluster_name = "dev-wordpress-cluster"
kubectl_config_command = "gcloud container clusters get-credentials..."
```

### Step 3: Configure kubectl

```bash
# Get credentials for the cluster
gcloud container clusters get-credentials dev-wordpress-cluster \
    --region us-central1 \
    --project YOUR_PROJECT_ID

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Step 4: Update Kubernetes Secrets (Optional)

For security, generate new passwords:

```bash
# Generate random password
openssl rand -base64 24

# Encode for Kubernetes secret
echo -n 'your-new-secure-password' | base64

# Update kubernetes/secrets.yaml with new values
```

### Step 5: Deploy Kubernetes Resources

**Option A: Using Kustomize (Recommended)**

```bash
cd kubernetes
kubectl apply -k .
```

**Option B: Apply individually**

```bash
cd kubernetes

# Create namespace first
kubectl apply -f namespace.yaml

# Wait for namespace
sleep 2

# Apply secrets and configmaps
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml

# Deploy MySQL
kubectl apply -f mysql/

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n wordpress --timeout=300s

# Deploy WordPress
kubectl apply -f wordpress/
```

### Step 6: Verify Deployment

```bash
# Check all resources
kubectl get all -n wordpress

# Check persistent volume claims
kubectl get pvc -n wordpress

# Check pod logs
kubectl logs -f deployment/mysql -n wordpress
kubectl logs -f deployment/wordpress -n wordpress
```

### Step 7: Access WordPress

```bash
# Get the external IP
kubectl get svc wordpress-service -n wordpress

# Wait for EXTERNAL-IP to be assigned (may take 2-5 minutes)
# Once assigned, access: http://EXTERNAL-IP
```

## Post-Deployment Setup

### Complete WordPress Installation

1. Open `http://EXTERNAL-IP` in your browser
2. Select your language
3. Enter site information:
   - Site Title: Your WordPress Site
   - Username: admin (choose your own)
   - Password: (use strong password)
   - Email: your-email@example.com
4. Click "Install WordPress"

### Verify Application Health

```bash
# Check pod health
kubectl get pods -n wordpress -o wide

# Check HPA status
kubectl get hpa -n wordpress

# View recent events
kubectl get events -n wordpress --sort-by='.lastTimestamp'
```

## Troubleshooting

### Pod Stuck in Pending

```bash
# Check pod events
kubectl describe pod <pod-name> -n wordpress

# Common causes:
# - Insufficient resources
# - PVC not bound
# - Node selector issues
```

### Database Connection Error

```bash
# Check MySQL logs
kubectl logs deployment/mysql -n wordpress

# Verify MySQL service
kubectl get svc mysql-service -n wordpress

# Test connection from WordPress pod
kubectl exec -it deployment/wordpress -n wordpress -- \
    nc -zv mysql-service 3306
```

### LoadBalancer IP Not Assigned

```bash
# Check service status
kubectl describe svc wordpress-service -n wordpress

# Check for events
kubectl get events -n wordpress | grep LoadBalancer

# Note: May take 2-5 minutes for GCP to provision
```

## Maintenance Commands

### Scale WordPress

```bash
# Manual scaling
kubectl scale deployment wordpress -n wordpress --replicas=3

# Check HPA
kubectl get hpa -n wordpress
```

### View Logs

```bash
# Stream WordPress logs
kubectl logs -f deployment/wordpress -n wordpress

# Stream MySQL logs
kubectl logs -f deployment/mysql -n wordpress
```

### Access Pod Shell

```bash
# WordPress container
kubectl exec -it deployment/wordpress -n wordpress -- /bin/bash

# MySQL container
kubectl exec -it deployment/mysql -n wordpress -- /bin/bash
```

### Update Deployment

```bash
# Update image
kubectl set image deployment/wordpress wordpress=wordpress:6.5 -n wordpress

# Check rollout status
kubectl rollout status deployment/wordpress -n wordpress

# Rollback if needed
kubectl rollout undo deployment/wordpress -n wordpress
```

## Cost Optimization Tips

1. **Use Preemptible VMs:** Already configured in Terraform
2. **Right-size nodes:** Start with e2-medium, adjust as needed
3. **Enable cluster autoscaler:** For production workloads
4. **Delete resources when not in use:** Use destroy.sh script
5. **Monitor costs:** Use GCP Cost Explorer

## Next Steps

1. Configure HTTPS with SSL certificate
2. Set up domain name
3. Configure backups
4. Implement monitoring with Prometheus/Grafana
5. Set up CI/CD pipeline

