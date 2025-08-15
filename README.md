# E-Commerce Infrastructure

Infrastructure as Code (IaC) for the E-Commerce platform supporting Docker, Kubernetes, and cloud deployments.

## Features

- Docker Compose for local development
- Kubernetes manifests for production
- Terraform for Azure infrastructure
- Helm charts for application deployment
- Environment-specific configurations
- Monitoring and observability stack

## Structure

```
├── docker/              # Docker configurations
├── kubernetes/          # Kubernetes manifests
├── terraform/           # Terraform modules
├── helm/               # Helm charts
├── monitoring/         # Monitoring stack
└── scripts/            # Utility scripts
```

## Quick Start

### Local Development
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down
```

### Kubernetes Deployment
```bash
# Deploy to staging
kubectl apply -f kubernetes/staging/

# Deploy to production
kubectl apply -f kubernetes/production/
```
