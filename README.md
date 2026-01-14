# Automated Deployment of Multi-tier WordPress Application on GKE

[![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-GKE-4285F4?style=flat&logo=google-cloud)](https://cloud.google.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-326CE5?style=flat&logo=kubernetes)](https://kubernetes.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Project Overview

This project demonstrates a comprehensive Infrastructure as Code (IaC) implementation for deploying a multi-tier WordPress application on Google Kubernetes Engine (GKE). It showcases DevOps best practices, container orchestration, and cloud-native deployment patterns.

**Author:** Mohd Sabir  
**Project Type:** MCA Final Project

### 🎯 Key Features

- **Infrastructure as Code (IaC):** Complete GCP infrastructure provisioned using Terraform
- **Container Orchestration:** Kubernetes-based deployment on GKE
- **Multi-tier Architecture:** WordPress frontend + MySQL backend
- **High Availability:** Horizontal Pod Autoscaling and multiple replicas
- **Security:** Private cluster, IAM roles, Kubernetes secrets
- **Persistence:** Persistent volumes for database and uploads
- **Networking:** VPC-native cluster with Cloud NAT

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Google Cloud Platform                           │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC Network (wordpress-vpc)                    │  │
│  │  ┌─────────────────────────────────────────────────────────────────┐  │  │
│  │  │                    Private Subnet (10.0.0.0/24)                  │  │  │
│  │  │  ┌───────────────────────────────────────────────────────────┐  │  │  │
│  │  │  │                  GKE Cluster (Private)                     │  │  │  │
│  │  │  │  ┌─────────────────────────────────────────────────────┐  │  │  │  │
│  │  │  │  │              Namespace: wordpress                    │  │  │  │  │
│  │  │  │  │  ┌──────────────────┐   ┌──────────────────────┐   │  │  │  │  │
│  │  │  │  │  │   WordPress      │   │      MySQL           │   │  │  │  │  │
│  │  │  │  │  │   Deployment     │   │      Deployment      │   │  │  │  │  │
│  │  │  │  │  │   (2+ replicas)  │──▶│      (1 replica)     │   │  │  │  │  │
│  │  │  │  │  │   Port: 80       │   │      Port: 3306      │   │  │  │  │  │
│  │  │  │  │  └────────┬─────────┘   └──────────┬───────────┘   │  │  │  │  │
│  │  │  │  │           │                        │               │  │  │  │  │
│  │  │  │  │  ┌────────▼─────────┐   ┌──────────▼───────────┐   │  │  │  │  │
│  │  │  │  │  │   WordPress PVC  │   │      MySQL PVC       │   │  │  │  │  │
│  │  │  │  │  │   (10Gi)         │   │      (10Gi)          │   │  │  │  │  │
│  │  │  │  │  └──────────────────┘   └──────────────────────┘   │  │  │  │  │
│  │  │  │  └─────────────────────────────────────────────────────┘  │  │  │  │
│  │  │  └───────────────────────────────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────────┐ │  │
│  │  │ Cloud Router │──│   Cloud NAT  │  │  Load Balancer (External IP) │ │  │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                              ┌───────────┐
                              │  Internet │
                              │   Users   │
                              └───────────┘
```

## 📁 Project Structure

```
mca-final-project/
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # Main Terraform configuration
│   ├── variables.tf              # Variable definitions
│   ├── outputs.tf                # Output definitions
│   ├── providers.tf              # Provider configuration
│   ├── terraform.tfvars.example  # Example variables file
│   └── modules/
│       ├── vpc/                  # VPC module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       ├── iam/                  # IAM module
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   └── outputs.tf
│       └── gke/                  # GKE module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── kubernetes/                   # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── secrets.yaml              # Secrets (database credentials)
│   ├── configmap.yaml            # ConfigMaps (MySQL, PHP config)
│   ├── mysql/
│   │   ├── deployment.yaml       # MySQL deployment
│   │   ├── service.yaml          # MySQL service (ClusterIP)
│   │   └── pvc.yaml              # Persistent volume claim
│   └── wordpress/
│       ├── deployment.yaml       # WordPress deployment
│       ├── service.yaml          # WordPress service (LoadBalancer)
│       ├── pvc.yaml              # Persistent volume claim
│       └── hpa.yaml              # Horizontal Pod Autoscaler
├── scripts/                      # Helper scripts
│   ├── deploy.sh                 # Full deployment script
│   ├── destroy.sh                # Teardown script
│   ├── validate.sh               # Validation script
│   └── status.sh                 # Status check script
├── .gitignore                    # Git ignore file
├── README.md                     # This file
└── project-proposal.txt          # Project proposal document
```

## 🛠️ Prerequisites

### Required Tools

| Tool | Version | Description |
|------|---------|-------------|
| [gcloud CLI](https://cloud.google.com/sdk/docs/install) | Latest | Google Cloud SDK |
| [Terraform](https://www.terraform.io/downloads) | >= 1.0.0 | Infrastructure provisioning |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | >= 1.28 | Kubernetes CLI |
| [Git](https://git-scm.com/) | Latest | Version control |

### GCP Requirements

- GCP account (Free tier works for testing)
- Project with billing enabled
- Owner or Editor role on the project

### Required GCP APIs

The following APIs need to be enabled (automatically enabled by Terraform):

- Compute Engine API
- Kubernetes Engine API
- Container Registry API
- Cloud Resource Manager API
- IAM API

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/mca-final-project.git
cd mca-final-project
```

### 2. Configure GCP Authentication

```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
```

### 3. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# IMPORTANT: Update project_id with your GCP project ID
```

### 4. Deploy Infrastructure

**Option A: Using the deployment script (recommended)**

```bash
cd scripts
chmod +x deploy.sh
./deploy.sh
```

**Option B: Manual deployment**

```bash
# Deploy Terraform infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Configure kubectl
gcloud container clusters get-credentials <cluster-name> --region <region>

# Deploy Kubernetes resources
cd ../kubernetes
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f configmap.yaml
kubectl apply -f mysql/
kubectl apply -f wordpress/
```

### 5. Access WordPress

```bash
# Get the external IP
kubectl get svc wordpress-service -n wordpress

# Access WordPress at http://<EXTERNAL-IP>
```

## 📊 Deployment Verification

### Check Deployment Status

```bash
# Run status script
cd scripts
./status.sh

# Or manually check:
kubectl get all -n wordpress
kubectl get pvc -n wordpress
kubectl get secrets -n wordpress
```

### Expected Output

```
NAME                             READY   STATUS    RESTARTS   AGE
pod/mysql-xxx                    1/1     Running   0          5m
pod/wordpress-xxx                1/1     Running   0          3m
pod/wordpress-yyy                1/1     Running   0          3m

NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)
service/mysql-service       ClusterIP      10.2.0.10      <none>          3306/TCP
service/wordpress-service   LoadBalancer   10.2.0.20      34.x.x.x        80:31xxx/TCP
```

## 🔧 Configuration Options

### Terraform Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `project_id` | Required | GCP Project ID |
| `region` | `us-central1` | GCP Region |
| `environment` | `dev` | Environment (dev/staging/prod) |
| `node_count` | `2` | Number of GKE nodes |
| `node_machine_type` | `e2-medium` | GKE node machine type |
| `mysql_storage_size` | `10Gi` | MySQL PVC size |
| `wordpress_storage_size` | `10Gi` | WordPress PVC size |

### Customizing Secrets

⚠️ **Important:** Always change default passwords in production!

```bash
# Generate base64 encoded passwords
echo -n 'your-secure-password' | base64

# Update kubernetes/secrets.yaml with your encoded passwords
```

## 🧹 Cleanup

To destroy all resources:

```bash
cd scripts
./destroy.sh
```

Or manually:

```bash
# Delete Kubernetes resources
kubectl delete namespace wordpress

# Destroy Terraform infrastructure
cd terraform
terraform destroy
```

## 🔒 Security Best Practices

1. **Secrets Management:**
   - Never commit actual secrets to Git
   - Use Google Secret Manager in production
   - Rotate credentials regularly

2. **Network Security:**
   - Private GKE cluster with Cloud NAT
   - Firewall rules restrict access
   - Master authorized networks configured

3. **IAM:**
   - Least privilege service accounts
   - Workload Identity for pod-level permissions

4. **Kubernetes:**
   - Network policies enabled
   - Pod security standards
   - Resource quotas and limits

## 📈 Scaling

### Horizontal Pod Autoscaling

WordPress is configured with HPA for automatic scaling:

```yaml
minReplicas: 2
maxReplicas: 5
targetCPUUtilizationPercentage: 70
```

### Manual Scaling

```bash
kubectl scale deployment wordpress -n wordpress --replicas=3
```

## 🐛 Troubleshooting

### Common Issues

**1. Pods stuck in Pending state:**
```bash
kubectl describe pod <pod-name> -n wordpress
# Check for resource constraints or PVC issues
```

**2. LoadBalancer IP not assigned:**
```bash
kubectl describe svc wordpress-service -n wordpress
# Wait 2-5 minutes for GCP to provision the load balancer
```

**3. Database connection errors:**
```bash
kubectl logs -f deployment/wordpress -n wordpress
# Verify MySQL is running and secrets are correct
```

**4. Terraform state issues:**
```bash
terraform state list
terraform state show <resource>
```

### Useful Commands

```bash
# View pod logs
kubectl logs -f deployment/wordpress -n wordpress

# Execute shell in pod
kubectl exec -it deployment/wordpress -n wordpress -- /bin/bash

# View events
kubectl get events -n wordpress --sort-by='.lastTimestamp'

# Port forwarding for debugging
kubectl port-forward svc/wordpress-service 8080:80 -n wordpress
```

## 📚 Learning Outcomes

This project demonstrates proficiency in:

- **Infrastructure as Code (IaC):** Terraform modules, state management, best practices
- **Google Cloud Platform:** VPC, GKE, IAM, Cloud NAT, Load Balancing
- **Kubernetes:** Deployments, Services, PVCs, ConfigMaps, Secrets, HPA
- **DevOps Practices:** Automation, reproducibility, documentation
- **Security:** Network security, IAM, secrets management

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Google Cloud Platform documentation
- Terraform Registry and documentation
- Kubernetes documentation
- WordPress and MySQL official Docker images

---

**Author:** Mohd Sabir  
**Project:** MCA Final Project  
**Institution:** [Your Institution Name]  
**Year:** 2026

