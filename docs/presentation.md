# MCA Final Project Presentation

## Automated Deployment of Multi-tier WordPress Application on GKE using Terraform

**Student:** Mohd Sabir  
**Course:** Master of Computer Applications (MCA)  
**Year:** 2026

---

# Slide 1: Title

## Automated Deployment of Multi-tier WordPress Application on GKE using Terraform

### Infrastructure as Code | Container Orchestration | Cloud-Native Deployment

**Mohd Sabir**  
MCA Final Project | 2026

---

# Slide 2: Agenda

1. Introduction & Problem Statement
2. Project Objectives
3. Technologies Used
4. System Architecture
5. Implementation Details
6. Live Demo
7. Challenges & Solutions
8. Learning Outcomes
9. Future Scope
10. Conclusion & Q&A

---

# Slide 3: Introduction

## What is this project about?

- **Infrastructure as Code (IaC)** approach to cloud deployment
- Automated provisioning of **Google Cloud Platform** resources
- Deploying a **multi-tier web application** on Kubernetes
- Demonstrating **DevOps best practices**

### Why WordPress + MySQL?

- Real-world multi-tier architecture
- Frontend (WordPress) + Backend (MySQL)
- Industry-standard deployment pattern

---

# Slide 4: Problem Statement

## Traditional Deployment Challenges

| Challenge | Impact |
|-----------|--------|
| Manual infrastructure setup | Time-consuming, error-prone |
| Inconsistent environments | "Works on my machine" problem |
| Difficult scaling | Cannot handle traffic spikes |
| No version control | Hard to track changes |
| Complex teardown | Resources left running = costs |

### Solution: Infrastructure as Code + Kubernetes

---

# Slide 5: Project Objectives

## Main Objectives

✅ **Automate** GCP infrastructure provisioning using Terraform

✅ **Deploy** multi-tier WordPress + MySQL on GKE

✅ **Implement** Kubernetes best practices:
   - Persistent Volumes
   - ConfigMaps & Secrets
   - Load Balancer Services
   - Health Checks

✅ **Document** the complete deployment workflow

✅ **Demonstrate** reproducible, scalable deployments

---

# Slide 6: Technologies Used

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Cloud Provider** | Google Cloud Platform | Infrastructure hosting |
| **IaC Tool** | Terraform | Resource provisioning |
| **Container Orchestration** | Kubernetes (GKE) | Application deployment |
| **Containerization** | Docker | Application packaging |
| **Frontend** | WordPress | Web application |
| **Database** | MySQL 8.0 | Data persistence |
| **Version Control** | Git & GitHub | Source code management |

---

# Slide 7: System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     INTERNET                                 │
│                         │                                    │
│                         ▼                                    │
│              ┌──────────────────────┐                       │
│              │   GCP Load Balancer  │                       │
│              └──────────┬───────────┘                       │
│ ┌───────────────────────┼───────────────────────────────┐   │
│ │            GKE Cluster (Kubernetes)                    │   │
│ │  ┌────────────────────┼────────────────────────────┐  │   │
│ │  │         Namespace: wordpress                     │  │   │
│ │  │  ┌─────────────────┴─────────────────────────┐  │  │   │
│ │  │  │                                           │  │  │   │
│ │  │  │  ┌───────────┐        ┌───────────┐      │  │  │   │
│ │  │  │  │ WordPress │───────▶│   MySQL   │      │  │  │   │
│ │  │  │  │  (2 pods) │        │  (1 pod)  │      │  │  │   │
│ │  │  │  └─────┬─────┘        └─────┬─────┘      │  │  │   │
│ │  │  │        │                    │            │  │  │   │
│ │  │  │  ┌─────▼─────┐        ┌─────▼─────┐      │  │  │   │
│ │  │  │  │   PVC     │        │    PVC    │      │  │  │   │
│ │  │  │  │  (10Gi)   │        │  (10Gi)   │      │  │  │   │
│ │  │  │  └───────────┘        └───────────┘      │  │  │   │
│ │  │  └───────────────────────────────────────────┘  │  │   │
│ │  └─────────────────────────────────────────────────┘  │   │
│ └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

# Slide 8: Terraform Infrastructure

## Infrastructure Components

### Terraform Modules Created:

| Module | Resources Created |
|--------|-------------------|
| **VPC Module** | VPC, Subnet, Firewall Rules, Cloud NAT, Cloud Router |
| **IAM Module** | Service Accounts, IAM Role Bindings |
| **GKE Module** | Kubernetes Cluster, Node Pool, Workload Identity |

### Key Features:
- Modular, reusable code
- Variable-driven configuration
- State management
- Dependency handling

---

# Slide 9: Terraform Code Structure

```
terraform/
├── main.tf              # Module orchestration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── providers.tf         # Provider configuration
└── modules/
    ├── vpc/             # Network infrastructure
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/             # Service accounts & roles
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── gke/             # Kubernetes cluster
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

# Slide 10: Kubernetes Components

## Kubernetes Resources Deployed

| Resource | Purpose |
|----------|---------|
| **Namespace** | Logical isolation for WordPress app |
| **Secrets** | Database credentials (base64 encoded) |
| **ConfigMaps** | MySQL & PHP configuration |
| **PersistentVolumeClaims** | Persistent storage for data |
| **Deployments** | WordPress (2 replicas), MySQL (1 replica) |
| **Services** | LoadBalancer (WordPress), ClusterIP (MySQL) |
| **HorizontalPodAutoscaler** | Auto-scaling based on CPU/Memory |

---

# Slide 11: Kubernetes Manifests Structure

```
kubernetes/
├── namespace.yaml       # wordpress namespace
├── secrets.yaml         # DB credentials
├── configmap.yaml       # MySQL & PHP config
├── kustomization.yaml   # Kustomize deployment
├── mysql/
│   ├── deployment.yaml  # MySQL pod
│   ├── service.yaml     # ClusterIP service
│   └── pvc.yaml         # Persistent storage
└── wordpress/
    ├── deployment.yaml  # WordPress pods
    ├── service.yaml     # LoadBalancer service
    ├── pvc.yaml         # Persistent storage
    └── hpa.yaml         # Auto-scaling
```

---

# Slide 12: Security Implementation

## Security Features

### Infrastructure Level:
- ✅ Private GKE cluster
- ✅ Cloud NAT for outbound traffic
- ✅ Firewall rules restricting access
- ✅ Least-privilege service accounts

### Application Level:
- ✅ Kubernetes Secrets for credentials
- ✅ Network policies enabled
- ✅ Shielded nodes with secure boot
- ✅ Workload Identity for pod authentication

---

# Slide 13: Deployment Workflow

## Automated Deployment Process

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   1. Init   │───▶│  2. Plan    │───▶│  3. Apply   │
│  terraform  │    │  terraform  │    │  terraform  │
└─────────────┘    └─────────────┘    └─────────────┘
                                             │
                                             ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  6. Access  │◀───│ 5. Deploy   │◀───│ 4. Configure│
│  WordPress  │    │  kubectl    │    │   kubectl   │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Single Command Deployment:
```bash
./scripts/deploy.sh
```

---

# Slide 14: Live Demo

## Demo Steps

1. **Show Terraform Code** - Infrastructure as Code
2. **Run Deployment Script** - Automated provisioning
3. **View GCP Console** - Created resources
4. **Access WordPress** - Working application
5. **Scale Application** - Kubernetes auto-scaling
6. **Destroy Infrastructure** - Clean teardown

### WordPress URL:
```
http://<EXTERNAL-IP>
```

---

# Slide 15: Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| **GCP Quota Limits** | Changed from regional to zonal cluster |
| **IAM Permission Errors** | Used Application Default Credentials |
| **MySQL Authentication** | Configured `mysql_native_password` |
| **Workload Identity Timing** | Added `depends_on` for GKE cluster |
| **Health Check Failures** | Changed to TCP + static file probes |

---

# Slide 16: Key Learnings

## Technical Skills Acquired

### Infrastructure as Code:
- Terraform modules and state management
- Provider configuration and dependencies

### Google Cloud Platform:
- VPC networking, subnets, firewall rules
- GKE cluster management
- IAM roles and service accounts

### Kubernetes:
- Deployments, Services, ConfigMaps, Secrets
- Persistent Volumes and Claims
- Health probes and auto-scaling

### DevOps Practices:
- Automation and scripting
- Documentation and version control

---

# Slide 17: Project Metrics

## Deployment Statistics

| Metric | Value |
|--------|-------|
| **Terraform Resources** | 15+ GCP resources |
| **Kubernetes Objects** | 12 manifests |
| **Lines of Code** | ~2000+ lines |
| **Deployment Time** | ~15-20 minutes |
| **Destroy Time** | ~10 minutes |

### Cost Optimization:
- Preemptible VMs (70% cost savings)
- Zonal cluster (vs regional)
- Auto-scaling for demand

---

# Slide 18: Future Scope

## Potential Enhancements

### Short Term:
- 🔒 HTTPS with SSL/TLS certificates
- 🌐 Custom domain configuration
- 📊 Prometheus + Grafana monitoring

### Medium Term:
- 🔄 CI/CD pipeline with GitHub Actions
- 🎯 ArgoCD for GitOps deployment
- 💾 Automated backup solution

### Long Term:
- 🌍 Multi-region deployment
- 🔄 Blue-green deployments
- 📈 Advanced auto-scaling policies

---

# Slide 19: Conclusion

## Project Summary

✅ Successfully automated GCP infrastructure provisioning

✅ Deployed production-ready WordPress on GKE

✅ Implemented Kubernetes best practices

✅ Created reusable, documented codebase

✅ Demonstrated DevOps workflow

### Key Takeaway:
> "Infrastructure as Code transforms manual, error-prone processes into automated, repeatable deployments."

---

# Slide 20: Thank You

## Questions & Discussion

### Project Repository:
```
github.com/yourusername/mca-final-project
```

### Contact:
**Mohd Sabir**  
MCA Final Project | 2026

---

## Thank You! 🙏

---

# Appendix: Commands Reference

## Quick Reference Commands

```bash
# Deploy infrastructure
cd terraform && terraform apply

# Configure kubectl
gcloud container clusters get-credentials <cluster> --zone <zone>

# Deploy application
kubectl apply -k kubernetes/

# Check status
kubectl get all -n wordpress

# Get WordPress URL
kubectl get svc wordpress-service -n wordpress

# Destroy everything
terraform destroy
```

