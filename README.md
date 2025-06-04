# EKS Demo

This project is a demo of how to deploy a microservices application to an Elastic Container Service (EKS) using Kubernetes, Helm, ArgoCD, Jenkins, and GitHub Actions.

## Overview

This project consists of three microservices: `auth`, `admin`, and `user`. These services are built using NestJS and are containerized using Docker. The services are then deployed to an EKS cluster using a Helm chart and ArgoCD.

## Branching Strategy

This repository uses four main branches: `main`, `develop`, `stage`, and `prod`.

- **main**: Used for continuous integration (CI). Commits to this branch trigger tests, build the application, and push Docker images to Docker Hub.
- **develop**: Used for ongoing development and feature integration.
- **stage**: ArgoCD watches this branch to automatically update resources in the staging environment.
- **prod**: ArgoCD watches this branch to automatically update resources in the production environment.

## Services

### Auth Service

The auth service is responsible for handling authentication and authorization. It uses a MongoDB database to store user credentials and provides an API for clients to authenticate and obtain an access token.

### Admin Service

The admin service is responsible for managing the application's admin users. It provides an API for creating, reading, updating, and deleting admin users.

### User Service

The user service is responsible for managing the application's users. It provides an API for creating, reading, updating, and deleting users.

## Requirements

You need to have the following tools installed on your machine:

- Docker
- Node.js (20 or later)
- Helm
- ArgoCD CLI
- Kubectl
- AWS CLI
- Kubernetes cluster (EKS)

## Setup

### Script Usage

The script `exec.sh` is a wrapper around the individual scripts in the `scripts` directory. It takes a single argument, which is the name of the script to run, and passes any additional arguments to that script.

The available commands are:

- `cluster`: Run the `cluster-setup.sh` script to set up the EKS cluster.
- `chart`: Run the `helm-charts-setup.sh` script to deploy services using helm.
- `ingress`: Runs the `ingress-setup.sh` script to set up the AWS Load Balancer Controller, provision ingress resources, and configure TLS/SSL using AWS Certificate Manager. Each ingress resource will have its own AWS load balancer automatically created and associated with the appropriate SSL certificate.
- `jenkins`: Run the `setup-jenkins.sh` script to set up the Jenkins server.
- `cert`: Run the `setup-cert_manager.sh` script to set up the cert-manager.
- `argocd`: Run the `setup-cert_manager.sh` script to set up the cert-manager.
- `mongo`: Run the `setup_mongodb.sh` script to set up the MongoDB database.
- `namespaces`: Run the `setup_namespaces.sh` script to set up the namespaces.
- `monitor`: Run the `setup-monitoring.sh` script to set up the monitoring for your infrastructure and workload using Prometheus and Grafana.

### Example Usage

Make the script executable:

```bash
chmod u+x ./exec.sh
```

Set up the EKS cluster:

```bash
./exec.sh cluster
```

Set up namespaces:

```bash
./exec.sh namespaces
```

Install the ingress controller:

```bash
./exec.sh ingress
```

Install ArgoCD:

```bash
./exec.sh argocd
```

Set up monitoring (Prometheus & Grafana):

```bash
./exec.sh monitor
```

Install MongoDB:

```bash
./exec.sh mongo
```

(Optional) Deploy services using Helm since you'll be deploying with argocd:

```bash
./exec.sh chart
```

(Optional) Set up Jenkins:

```bash
./exec.sh jenkins
```

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository and create your branch from `develop`.
2. Make your changes and ensure code quality and tests pass.
3. Submit a pull request to the `develop` branch with a clear description of your changes.
4. Address any review comments and update your pull request as needed.

Please follow the existing code style and include relevant documentation or tests with your contribution.
