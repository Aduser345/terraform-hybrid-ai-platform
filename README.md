# Universal AI Context Broker (Hybrid GKE & Cloud Run)

A secure, production-grade hybrid cloud infrastructure deployed via Terraform on Google Cloud Platform (GCP). This architecture provisions a secure Kubernetes foundation alongside a serverless Model Context Protocol (MCP) broker, acting as a centralized context hub for heterogeneous AI models.

## 🏗️ Architecture Overview

This project uses Terraform to provision a hybrid cloud environment, prioritizing security, private networking, and the Principle of Least Privilege.

**Part 1: The Kubernetes Foundation (GKE)**
* **Networking:** Custom VPC, Cloud NAT, and strict Network-level Firewall rules (Target Tags).
* **Compute:** Private GKE Cluster with autoscaling Node Pools and zero-downtime upgrades.
* **Identity:** Workload Identity for pod-level, keyless GCP authentication.

**Part 2: The Universal AI Context Broker (Cloud Run)**
* **Compute:** Serverless Google Cloud Run deployment for Model Context Protocol (MCP) interactions.
* **Storage:** GCS bucket with strict uniform bucket-level access for AI context persistence.
* **Security:** Secrets dynamically mounted into container memory via GCP Secret Manager.

## 📂 Module Structure

The project is broken down into highly cohesive, decoupled modules:

### Core Infrastructure
- `/modules/vpc`: Provisions a custom VPC network with secondary IP ranges for VPC-native GKE networking.
- `/modules/firewall`: Implements stateless GCP firewall rules (Target Tags) for IAP SSH, internal traffic, and load balancing.
- `/modules/iam`: Centralized identity management provisioning dedicated Service Accounts for both GKE nodes and the Cloud Run broker.

### Compute & Application Layers
- `/modules/gke`: Deploys a Private Kubernetes Engine cluster with managed node pools, shielded VMs, and integrated Prometheus.
- `/modules/cloud_run_mcp`: The core serverless engine running the MCP Docker container, secured behind internal ingress.

### Data & Security Layers
- `/modules/storage_context`: Deploys a GCS bucket for AI context persistence, enforcing uniform bucket-level access and blocking public exposure.
- `/modules/secret_manager`: Provisions secure vaults for external AI API keys, mounted dynamically at runtime to prevent secret leakage.

## 🚀 Deployment Instructions

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed (`>= 1.5.0`).
- Google Cloud SDK (`gcloud`) installed and authenticated.
- A GCP Project with billing enabled.
- Required APIs enabled (`container.googleapis.com`, `compute.googleapis.com`, `iam.googleapis.com`, `secretmanager.googleapis.com`, `run.googleapis.com`).

### Execution
1. **Authenticate to GCP:**
   ```bas
   gcloud auth application-default login
   ```
2. **Initialize Terraform:**
   ```bash
   terraform init
   ```
3. **Review the Execution Plan:**
   ```bash
   terraform plan -var="project_id=YOUR_PROJECT_ID" -var="environment=dev"
   ```
4. **Apply the Infrastructure:**
   ```bash
   terraform apply
   ```

## 🔐 Security Posture

- This architecture explicitly mitigates common cloud and AI agent vulnerabilities:
- Tool Poisoning Mitigation: Context storage is isolated and Cloud Run invoker permissions are strictly limited.
- Keyless Authentication: Relies entirely on GCP Service Accounts and Workload Identity; no long-lived JSON keys are generated.
- Zero Public Exposure: GKE nodes are completely private (using Cloud NAT for outbound traffic), and the MCP broker relies on internal ingress.