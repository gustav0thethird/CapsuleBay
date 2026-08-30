# Repository Structure

The CapsuleBay repository is organized into several directories and key files, each serving a specific purpose in the overall architecture of the project. Below is a detailed description of the repository structure.

```
.
├── Jenkinsfile                  # Main CapsuleBay pipeline
├── .github/workflows/           # Cloud-side validation
│   ├── capsulebay-build.yml     # Trivy image validation
│   └── snyk-dockerfile.yml      # Snyk Dockerfile scanning
├── infra/                       # Local infrastructure setup
│   ├── setup.sh                 # Script to set up infrastructure services
│   └── docker-compose.yml       # Docker Compose configuration for infrastructure
├── n8n/                         # Self-contained capsule for n8n service
│   ├── Dockerfile               # Dockerfile for n8n
│   └── docker-compose.yml       # Docker Compose configuration for n8n
├── portainer/                   # Self-contained capsule for Portainer service
│   ├── Dockerfile               # Dockerfile for Portainer
│   └── docker-compose.yml       # Docker Compose configuration for Portainer
└── whoami/                      # Self-contained capsule for whoami service
    ├── Dockerfile               # Dockerfile for whoami
    └── docker-compose.yml       # Docker Compose configuration for whoami
```

## Directory and File Descriptions

- **Jenkinsfile**: This file defines the main CI/CD pipeline for CapsuleBay, orchestrating the build, scan, and deployment processes.

- **.github/workflows/**: This directory contains GitHub Actions workflows for cloud-side validation.
  - **capsulebay-build.yml**: Configures the workflow for building Docker images and performing security scans using Trivy on push and pull request events.
  - **snyk-dockerfile.yml**: Sets up a workflow to scan Dockerfiles for vulnerabilities using Snyk on various events.

- **infra/**: This directory is responsible for setting up the local infrastructure required for CapsuleBay.
  - **setup.sh**: A script that automates the setup of infrastructure services, including creating necessary directories and configuring Vault.
  - **docker-compose.yml**: Defines the Docker Compose configuration for setting up services like Vault and a Docker registry.

- **n8n/**: Contains the self-contained capsule for the n8n workflow automation tool.
  - **Dockerfile**: Specifies the image build instructions for n8n.
  - **docker-compose.yml**: Configures the Docker services for running n8n, including environment variables and port mappings.

- **portainer/**: Contains the self-contained capsule for the Portainer management UI.
  - **Dockerfile**: Specifies the image build instructions for Portainer.
  - **docker-compose.yml**: Configures the Docker services for running Portainer.

- **whoami/**: Contains the self-contained capsule for the whoami service, which provides a simple HTTP server for testing.
  - **Dockerfile**: Specifies the image build instructions for the whoami service.
  - **docker-compose.yml**: Configures the Docker services for running the whoami service.

## Adding a New Capsule

To add a new service (capsule) to the repository:
1. Create a new directory for the service (e.g., `myservice/`).
2. Add a `Dockerfile` and a `docker-compose.yml` file within that directory.
3. Update the Jenkins `SERVICE` parameter list to include the new service name.

This process allows CapsuleBay to automatically build, scan, and deploy the new capsule without requiring additional pipeline edits or scripts.
