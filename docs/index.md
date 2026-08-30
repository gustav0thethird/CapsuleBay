# CapsuleBay Overview

CapsuleBay is a hybrid CI/CD framework designed for modular, image-based capsule deployments, incorporating integrated security scanning and secret management. It automates the entire **build → push → scan → deploy** pipeline across both GitHub Actions and Jenkins, ensuring a streamlined and secure deployment process.

## Key Features

- **Self-contained Deployment Capsules**: Each service is encapsulated in a Docker image that includes its own `docker-compose.yml` and configuration logic, eliminating dependencies on external scripts or Git state.
  
- **Vault-based Secret Management**: Secrets are securely managed and injected into the deployment process using HashiCorp Vault.

- **Per-service Modular Builds**: Each service can be built independently, allowing for flexibility and scalability.

- **Immutable Image Capsules**: Each capsule is versioned and tagged, ensuring consistency across deployments.

- **Automated VM Lifecycle Management**: Integration with the Proxmox API allows for automated management of virtual machines.

- **Integrated Security Scanning**: Utilizes tools like Trivy and Snyk to scan for vulnerabilities in images and Dockerfiles.

- **Discord Notifications**: Automated notifications provide updates on build status, including links, timestamps, and durations.

## System Architecture

CapsuleBay operates on two distinct CI/CD layers:

### 1. GitHub Actions – Cloud Validation Layer
- Automatically triggers on every push or pull request.
- Builds capsule images for validation.
- Executes Trivy scans for vulnerabilities.
- Runs Snyk scans for dependency-level issues.
- Uploads scan reports as artifacts for review.

### 2. Jenkins – Self-Hosted Deployment Layer
- Manages controlled, Vault-secured deployments within your local network.
- Builds, tags, and pushes capsule images to a local registry.
- Retrieves secrets dynamically from Vault.
- Ensures the target VM is powered on via the Proxmox API.
- Rescans built images using Trivy before deployment.
- Deploys capsules remotely with embedded `docker-compose.yml`.
- Sends Discord notifications with relevant build information.

## Getting Started

### Deploy the Core Infrastructure
To set up the necessary infrastructure, run the following command:
```bash
cd infra
sudo ./setup.sh
```
This script will:
- Detect your LAN IP automatically.
- Create a `.env` and `.secrets` file with generated credentials.
- Deploy Vault, a local image registry, and an optional registry UI.

### Repository Structure
```
.
├── Jenkinsfile                  # Main CapsuleBay pipeline
├── .github/workflows/           # Cloud-side validation
│   ├── capsulebay-build.yml     # Trivy image validation
│   └── snyk-dockerfile.yml      # Snyk Dockerfile scanning
├── infra/                       # Local infrastructure setup
│   ├── setup.sh
│   └── docker-compose.yml
├── n8n/
│   ├── Dockerfile
│   └── docker-compose.yml
├── portainer/
│   ├── Dockerfile
│   └── docker-compose.yml
└── whoami/
    ├── Dockerfile
    └── docker-compose.yml
```
Each service directory contains its own Dockerfile and `docker-compose.yml`, making them self-contained capsules.

## Adding a New Capsule
To add a new service:
1. Create a folder for the service, e.g., `myservice/`.
2. Add a `Dockerfile` and `docker-compose.yml`.
3. Update the Jenkins `SERVICE` parameter list.

CapsuleBay will automatically handle the build, scan, and deployment processes without requiring additional pipeline edits.

## Security Stack
CapsuleBay integrates multiple layers of security checks:
- **Pre-merge**: Trivy scans built images for vulnerabilities.
- **Dependency Scanning**: Snyk scans Dockerfiles for CVEs.
- **Pre-deploy**: Jenkins rescans the final image before deployment.
- **Secret Management**: HashiCorp Vault securely manages and delivers secrets.

## Discord Notifications
At the end of each pipeline run, CapsuleBay sends a Discord notification with:
- Service name
- Environment
- Build link
- Duration
- Timestamp

This ensures that the team is informed of the deployment status in real-time.

## Conclusion
CapsuleBay provides a robust framework for managing CI/CD processes with a focus on security, modularity, and ease of use. By encapsulating services into self-contained deployment units, it simplifies the deployment process while maintaining high standards of security and efficiency.
