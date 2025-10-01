# Azure Multi-Tier Portfolio Infrastructure

A comprehensive Azure infrastructure deployment using Terraform that implements a secure, scalable multi-tier architecture for an insurance platform. This infrastructure follows Azure best practices with hub-and-spoke network topology, private AKS clusters, and environment-specific configurations.

## 🏗️ Architecture Overview

This infrastructure deploys a production-ready, multi-tier application platform with the following key components:

- **Hub-and-Spoke Network Architecture**: Centralized management with isolated workload networks
- **Private Azure Kubernetes Service (AKS)**: Secure container orchestration platform
- **Application Gateway with AGIC**: Load balancing and ingress management
- **PostgreSQL Flexible Server**: Managed database with high availability
- **Azure Key Vault**: Centralized secrets and certificate management
- **Blob Storage**: Scalable object storage for application data
- **Workload Identity**: Secure pod-to-Azure resource authentication

## Network Diagram

![Network Architecture Diagram](networkdiagram.png)

## 🌍 Environments

### Production Environment
- **Location**: West Europe
- **Hub Network**: `100.23.0.0/21`
- **Spoke Network**: `110.10.0.0/21`
- **AKS Nodes**: 2-10 (auto-scaling)
- **Database**: Private access with read replica
- **Features**: VPN connectivity, premium ACR, enhanced security

### Staging Environment
- **Location**: West Europe
- **Hub Network**: `100.21.0.0/22`
- **Spoke Network**: `100.21.4.0/22`
- **AKS Nodes**: 3-20 (auto-scaling)
- **Database**: Public access for development
- **Features**: Relaxed security for testing, basic ACR

## 🚀 Quick Start

### Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 0.12 installed
3. **Azure subscription** with appropriate permissions
4. **Service Principal** or **Managed Identity** for Terraform

### Authentication Setup

```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Create service principal (if needed)
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/your-subscription-id"
```

### Deployment Commands

#### Staging Environment
```bash
# Initialize Terraform with staging backend
terraform init -backend-config=environments/staging/staging.conf

# Plan the deployment
terraform plan --var-file=environments/staging/staging.tfvars

# Apply the configuration
terraform apply --var-file=environments/staging/staging.tfvars
```

#### Production Environment
```bash
# Initialize Terraform with production backend
terraform init --backend-config=environments/production/production.conf

# Plan the deployment
terraform plan --var-file=environments/production/production.tfvars

# Apply the configuration
terraform apply --var-file=environments/production/production.tfvars
```

## 📁 Project Structure

```
azure-multi-tier-portfolio/
├── environments/
│   ├── production/
│   │   ├── production.conf      # Backend configuration
│   │   └── production.tfvars    # Production variables
│   └── staging/
│       ├── staging.conf         # Backend configuration
│       └── staging.tfvars       # Staging variables
├── modules/
│   ├── blob-storage/           # Storage account module
│   ├── dns/                    # DNS management
│   ├── firewall/              # Azure Firewall (optional)
│   ├── jumpbox/               # Bastion VM
│   ├── natgw/                 # NAT Gateway
│   ├── nsg/                   # Network Security Groups
│   ├── postgress_flexible_server/ # PostgreSQL database
│   ├── redis/                 # Redis cache (optional)
│   ├── route_table/           # Custom routing
│   ├── vnet/                  # Virtual Network
│   └── vnet_peering/          # Network peering
├── values/
│   └── ingress/
│       └── ingress.yaml       # Ingress controller values
├── main.tf                    # Main infrastructure
├── aks.tf                     # AKS cluster configuration
├── api-gateway-prod.tf        # Production API Gateway
├── api-gateway-staging.tf     # Staging API Gateway
├── backend.tf                 # Terraform backend
├── blob-storage.tf            # Storage configuration
├── dns.tf                     # DNS configuration
├── keyvaults.tf              # Key Vault setup
├── locals.tf                 # Local values
├── variables.tf              # Variable definitions
├── vpn-prod.tf               # VPN configuration
├── workload-identity.tf      # Workload identity setup
└── README.md                 # This file
```

## 🔧 Key Components

### Network Architecture
- **Hub VNet**: Contains shared services (jumpbox, API gateway)
- **Spoke VNet**: Contains AKS cluster and application workloads
- **VNet Peering**: Secure communication between hub and spoke
- **NAT Gateway**: Controlled outbound internet access
- **Route Tables**: Custom routing for security and compliance

### Compute Resources
- **Private AKS Cluster**: Kubernetes 1.31 with no public endpoints
- **Application Gateway**: Layer 7 load balancer with WAF capabilities
- **Jumpbox VM**: Secure access point for cluster management
- **Auto-scaling**: Dynamic node scaling based on workload demands

### Data Layer
- **PostgreSQL Flexible Server**: Managed database with backup and HA
- **Azure Blob Storage**: Object storage for media and documents
- **Azure Container Registry**: Private container image repository

### Security
- **Private Endpoints**: Secure connectivity to Azure services
- **Network Security Groups**: Granular network access control
- **Azure Key Vault**: Centralized secrets management
- **Workload Identity**: Pod-level authentication to Azure resources
- **RBAC**: Role-based access control throughout the infrastructure

## 🔐 Security Features

- **Zero Trust Network**: All communication secured by default
- **Private AKS**: No public API server endpoint
- **Encrypted Storage**: All data encrypted at rest and in transit
- **Network Segmentation**: Isolated subnets with controlled access
- **Identity Management**: Azure AD integration with RBAC
- **Secret Management**: Centralized secret storage and rotation

## 📊 Monitoring and Management

### Access Management
```bash
# Connect to jumpbox for cluster access
az vm run-command invoke \
  --resource-group <resource-group> \
  --name <jumpbox-name> \
  --command-id RunShellScript \
  --scripts "kubectl get nodes"
```

### Database Access
- **Production**: Private endpoint access only
- **Staging**: Public access with firewall rules
- **Backup**: Automated daily backups with 7-day retention

## 🔄 CI/CD Integration

This infrastructure supports GitOps workflows with:
- **Application Gateway Ingress Controller (AGIC)**: Automatic ingress management
- **Workload Identity**: Secure pod authentication
- **Container Registry**: Private image storage
- **Key Vault Integration**: Secret injection into pods

## 📈 Scaling and Performance

- **AKS Auto-scaling**: Horizontal pod and cluster auto-scaling
- **Application Gateway**: Multi-instance deployment for HA
- **Database Scaling**: Vertical scaling with minimal downtime
- **Storage**: Automatic scaling with performance tiers

## 🛠️ Customization

### Environment Variables
Key variables can be customized in the respective `.tfvars` files:
- Network CIDR ranges
- VM sizes and node counts
- Database configurations
- Storage account settings

### Module Configuration
Individual modules can be customized by modifying their respective files in the `modules/` directory.

## 🚨 Troubleshooting

### Common Issues
1. **AKS Access**: Use jumpbox for private cluster access
2. **Network Connectivity**: Check NSG rules and route tables
3. **Database Connection**: Verify firewall rules and private endpoints
4. **Storage Access**: Confirm RBAC permissions and network access

### Useful Commands
```bash
# Check AKS cluster status
kubectl get nodes

# View ingress controllers
kubectl get ingress -A

# Check pod logs
kubectl logs -f <pod-name> -n <namespace>
```

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in staging environment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Support

For support and questions:
- Create an issue in this repository
- Review the troubleshooting section
- Check Azure documentation for service-specific issues
