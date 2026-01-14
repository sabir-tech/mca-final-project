# Architecture Documentation

## System Architecture Overview

This document describes the architecture of the multi-tier WordPress application deployed on Google Kubernetes Engine (GKE).

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    INTERNET                                          │
│                                        │                                             │
│                                        ▼                                             │
│                            ┌──────────────────────┐                                  │
│                            │   GCP Load Balancer  │                                  │
│                            │   (External IP)      │                                  │
│                            └──────────┬───────────┘                                  │
└───────────────────────────────────────┼──────────────────────────────────────────────┘
                                        │
┌───────────────────────────────────────┼──────────────────────────────────────────────┐
│                        Google Cloud Platform                                          │
│  ┌────────────────────────────────────┼───────────────────────────────────────────┐  │
│  │                VPC Network: wordpress-vpc                                       │  │
│  │                                    │                                            │  │
│  │  ┌─────────────────────────────────┼────────────────────────────────────────┐  │  │
│  │  │              Private Subnet: 10.0.0.0/24                                  │  │  │
│  │  │                                 │                                         │  │  │
│  │  │  ┌──────────────────────────────┼──────────────────────────────────────┐ │  │  │
│  │  │  │              GKE Cluster (Regional, Private)                         │ │  │  │
│  │  │  │                              │                                       │ │  │  │
│  │  │  │  ┌───────────────────────────┼────────────────────────────────────┐ │ │  │  │
│  │  │  │  │           Namespace: wordpress                                  │ │ │  │  │
│  │  │  │  │                           │                                     │ │ │  │  │
│  │  │  │  │  ┌────────────────────────┴────────────────────────┐           │ │ │  │  │
│  │  │  │  │  │                                                  │           │ │ │  │  │
│  │  │  │  │  │  ┌─────────────────┐      ┌─────────────────┐   │           │ │ │  │  │
│  │  │  │  │  │  │   WordPress     │      │     MySQL       │   │           │ │ │  │  │
│  │  │  │  │  │  │   Deployment    │─────▶│   Deployment    │   │           │ │ │  │  │
│  │  │  │  │  │  │                 │      │                 │   │           │ │ │  │  │
│  │  │  │  │  │  │  ┌───────────┐  │      │  ┌───────────┐  │   │           │ │ │  │  │
│  │  │  │  │  │  │  │  Pod 1    │  │      │  │  Pod 1    │  │   │           │ │ │  │  │
│  │  │  │  │  │  │  │  (nginx+  │  │      │  │  (mysql8) │  │   │           │ │ │  │  │
│  │  │  │  │  │  │  │  php-fpm) │  │      │  │           │  │   │           │ │ │  │  │
│  │  │  │  │  │  │  └───────────┘  │      │  └───────────┘  │   │           │ │ │  │  │
│  │  │  │  │  │  │  ┌───────────┐  │      │        │        │   │           │ │ │  │  │
│  │  │  │  │  │  │  │  Pod 2    │  │      │        ▼        │   │           │ │ │  │  │
│  │  │  │  │  │  │  │  (replica)│  │      │  ┌───────────┐  │   │           │ │ │  │  │
│  │  │  │  │  │  │  └───────────┘  │      │  │   PVC     │  │   │           │ │ │  │  │
│  │  │  │  │  │  │        │        │      │  │  (10Gi)   │  │   │           │ │ │  │  │
│  │  │  │  │  │  │        ▼        │      │  └───────────┘  │   │           │ │ │  │  │
│  │  │  │  │  │  │  ┌───────────┐  │      │                 │   │           │ │ │  │  │
│  │  │  │  │  │  │  │   PVC     │  │      └─────────────────┘   │           │ │ │  │  │
│  │  │  │  │  │  │  │  (10Gi)   │  │                            │           │ │ │  │  │
│  │  │  │  │  │  │  └───────────┘  │                            │           │ │ │  │  │
│  │  │  │  │  │  │                 │                            │           │ │ │  │  │
│  │  │  │  │  │  └─────────────────┘                            │           │ │ │  │  │
│  │  │  │  │  │                                                  │           │ │ │  │  │
│  │  │  │  │  │  ┌─────────────────────────────────────────────┐│           │ │ │  │  │
│  │  │  │  │  │  │         Services                            ││           │ │ │  │  │
│  │  │  │  │  │  │  ┌────────────────┐  ┌───────────────────┐  ││           │ │ │  │  │
│  │  │  │  │  │  │  │ wordpress-svc  │  │    mysql-svc      │  ││           │ │ │  │  │
│  │  │  │  │  │  │  │ (LoadBalancer) │  │   (ClusterIP)     │  ││           │ │ │  │  │
│  │  │  │  │  │  │  │   Port: 80     │  │    Port: 3306     │  ││           │ │ │  │  │
│  │  │  │  │  │  │  └────────────────┘  └───────────────────┘  ││           │ │ │  │  │
│  │  │  │  │  │  └─────────────────────────────────────────────┘│           │ │ │  │  │
│  │  │  │  │  └──────────────────────────────────────────────────┘           │ │ │  │  │
│  │  │  │  └──────────────────────────────────────────────────────────────────┘ │ │  │  │
│  │  │  └────────────────────────────────────────────────────────────────────────┘ │  │  │
│  │  │                                                                              │  │  │
│  │  │  ┌──────────────────────┐    ┌──────────────────────┐                       │  │  │
│  │  │  │    Cloud Router      │───▶│     Cloud NAT        │                       │  │  │
│  │  │  │    (BGP ASN: 64514)  │    │  (Outbound Internet) │                       │  │  │
│  │  │  └──────────────────────┘    └──────────────────────┘                       │  │  │
│  │  └──────────────────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                          │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐   │
│  │                          IAM Service Accounts                                     │   │
│  │   ┌─────────────────────┐              ┌─────────────────────────┐               │   │
│  │   │  GKE Node SA        │              │  WordPress Workload SA  │               │   │
│  │   │  - logging.writer   │              │  - storage.objectAdmin  │               │   │
│  │   │  - monitoring.write │              │  - workloadIdentity     │               │   │
│  │   │  - storage.viewer   │              │                         │               │   │
│  │   └─────────────────────┘              └─────────────────────────┘               │   │
│  └──────────────────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Network Layer

| Component | Description |
|-----------|-------------|
| **VPC Network** | Custom VPC with auto-subnets disabled for full control |
| **Subnet** | Primary: 10.0.0.0/24, Pods: 10.1.0.0/16, Services: 10.2.0.0/20 |
| **Cloud Router** | Enables Cloud NAT for outbound connectivity |
| **Cloud NAT** | Provides internet access for private nodes |
| **Firewall Rules** | Internal communication, health checks, SSH via IAP |

### 2. GKE Cluster

| Feature | Configuration |
|---------|---------------|
| **Type** | Regional, Private cluster |
| **Node Pool** | Preemptible e2-medium instances |
| **Workload Identity** | Enabled for secure pod authentication |
| **Network Policy** | Calico for pod network policies |
| **Logging/Monitoring** | Cloud Logging and Monitoring enabled |

### 3. Application Layer

#### WordPress (Frontend)
- **Image:** wordpress:6.4-php8.2-apache
- **Replicas:** 2 (with HPA, max 5)
- **Service:** LoadBalancer (external access)
- **Storage:** 10Gi PVC for wp-content

#### MySQL (Backend)
- **Image:** mysql:8.0
- **Replicas:** 1 (stateful workload)
- **Service:** ClusterIP (internal only)
- **Storage:** 10Gi PVC for database

### 4. Security

- Private GKE cluster with private nodes
- Service accounts with least privilege
- Kubernetes Secrets for sensitive data
- Network policies for pod-to-pod security
- Shielded nodes with secure boot

## Data Flow

1. **User Request:** Internet → Load Balancer → WordPress Service
2. **WordPress Processing:** WordPress Pod → MySQL Service → MySQL Pod
3. **Database Query:** MySQL Pod → PVC (Persistent Disk)
4. **Response:** MySQL → WordPress → User

## Scaling Strategy

```
                    ┌─────────────────────────┐
                    │  Horizontal Pod         │
                    │  Autoscaler (HPA)       │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │  CPU/Memory Metrics     │
                    │  Target: 70%/80%        │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│  WordPress    │      │  WordPress    │      │  WordPress    │
│  Pod 1        │      │  Pod 2        │  ... │  Pod N        │
│  (min: 2)     │      │               │      │  (max: 5)     │
└───────────────┘      └───────────────┘      └───────────────┘
```

## Disaster Recovery

| Aspect | Strategy |
|--------|----------|
| **Data Persistence** | GCE Persistent Disks with regional redundancy |
| **Application State** | Stateless WordPress pods, state in MySQL |
| **Cluster Recovery** | Regional cluster for zone failure tolerance |
| **Backup** | PVC snapshots (recommended for production) |

