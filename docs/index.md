# Overview

CapsuleBay is a hybrid CI/CD framework designed for modular, image-based deployments using self-contained deployment capsules. Each capsule is a Docker image that includes its own `docker-compose.yml` and configuration logic, allowing for independent builds and deployments without reliance on external scripts or Git state.

The CapsuleBay system automates the entire **build → push → scan → deploy** pipeline, integrating key features such as:

- **Vault-based secret management**: Securely manage and inject secrets during deployment.
- **Per-service modular builds**: Each service is encapsulated in its own Docker image.
- **Immutable image capsules**: Ensures consistency and reliability in deployments.
- **Automated VM lifecycle management**: Utilizes the Proxmox API to manage virtual machines.
- **Integrated security scanning**: Employs tools like Trivy and Snyk to scan for vulnerabilities.
- **Discord notifications**: Provides real-time updates on build status, including links and timestamps.

## System Architecture

CapsuleBay operates through two primary CI/CD layers:

### 1. GitHub Actions – Cloud Validation Layer
This layer automatically triggers on every push or pull request, performing the following tasks:
- Builds capsule images for validation.
- Executes Trivy image scans for vulnerabilities.
- Runs Snyk Dockerfile scans for dependency issues.
- Uploads scan reports as artifacts for review.

### 2. Jenkins – Self-Hosted Deployment Layer
This layer manages controlled deployments within your local network, executing the following:
- Builds, tags, and pushes capsule images to a local registry.
- Retrieves secrets dynamically from Vault.
- Ensures the target VM is powered on using the Proxmox API.
- Rescans built images with Trivy before deployment.
- Deploys capsules remotely using the embedded `docker-compose.yml`.
- Sends notifications via Discord with relevant build information.

## Getting Started

To deploy the core infrastructure for CapsuleBay, run the following command:

```bash
cd infra
sudo ./setup.sh
```

This script will:
- Automatically detect your LAN IP.
- Create necessary `.env` and `.secrets` files with generated credentials.
- Deploy Vault, a local image registry, and an optional registry UI.

After setup, the following services will be available:

| Service | Purpose | URL |
|----------|----------|-----|
| Vault | Secret storage for Jenkins & services | `http://<LAN_IP>:8200` |
| Registry | Local image registry | `http://<LAN_IP>:5000` |
| Registry UI | Optional web dashboard | `http://<LAN_IP>:5001` |

## Repository Structure

The CapsuleBay repository is organized as follows:

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

Each service directory (except `infra/`) contains a self-contained capsule.

## Adding a New Capsule

To add a new service, follow these steps:

1. Create a new folder, e.g., `myservice/`.
2. Add a `Dockerfile` and `docker-compose.yml` in the folder.
3. Include the folder name in the Jenkins `SERVICE` parameter list.

CapsuleBay will automatically handle the build, push, scan, and deployment processes without requiring additional pipeline edits or scripts.

## Security Stack

CapsuleBay incorporates multiple layers of security checks:

| Layer | Tool | Purpose |
|--------|------|----------|
| GitHub Actions (pre-merge) | Trivy | Scan built images for vulnerabilities |
| | Snyk | Scan Dockerfiles for dependency CVEs |
| Jenkins (pre-deploy) | Trivy CLI | Rescan final image before deployment |
| Vault | HashiCorp Vault | Securely manage and deliver secrets |
| Discord | Webhook alerts | Notify on success or failure with build links |

## Discord Notifications

At the end of each pipeline run, CapsuleBay sends a Discord notification containing:

- Service name  
- Environment  
- Build link  
- Duration  
- Timestamp  
- User ping  

This ensures that the team is informed of the deployment status in real-time.

## Conclusion

CapsuleBay provides a robust framework for managing modular, image-based deployments with integrated security scanning and secret management. Its architecture supports both cloud validation and self-hosted deployments, ensuring a secure and efficient CI/CD process.
