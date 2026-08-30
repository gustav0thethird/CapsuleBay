# System Architecture

## CI/CD Architecture Overview

The CapsuleBay project employs a hybrid CI/CD architecture that integrates GitHub Actions and Jenkins for modular, image-based deployments with a focus on security scanning.

### GitHub Actions

The CI/CD pipeline is primarily managed through GitHub Actions, which automates the build and security scanning processes. There are two main workflows defined in the `.github/workflows` directory:

1. **CI.yml**: This workflow is triggered on pushes and pull requests to any branch. It includes the following jobs:
   - **Checkout**: Uses the `actions/checkout@v4` action to pull the repository code.
   - **Set up Docker Buildx**: Configures Docker Buildx for building images.
   - **Build images**: Utilizes `docker/build-push-action@v5` to build Docker images for validation.
   - **Security Scan (Trivy)**: Runs a security scan using the Trivy action to identify vulnerabilities in the built images, specifically targeting high and critical severity issues.

2. **snyk.yml**: This workflow is also triggered on pushes and pull requests, as well as manually via workflow dispatch. It includes:
   - **Checkout code**: Similar to the CI.yml workflow, it checks out the code.
   - **Set up Docker and Snyk**: Installs Snyk and authenticates using a secret token.
   - **Build and scan all Dockerfiles**: Searches for Dockerfiles in the repository, builds Docker images, and scans them for vulnerabilities using Snyk, reporting any issues with a severity threshold set to high.

### Jenkins Integration

In addition to GitHub Actions, CapsuleBay utilizes Jenkins for certain CI/CD tasks. The Jenkins pipeline is defined in the `Jenkinsfile`, which outlines the steps for building, testing, and deploying applications. The specifics of the Jenkins pipeline are not detailed in the provided files, but it typically includes stages for building Docker images, running tests, and deploying to various environments.

### Security Considerations

Both GitHub Actions workflows incorporate security scanning tools (Trivy and Snyk) to ensure that vulnerabilities are identified early in the development process. This focus on security is a critical aspect of the CI/CD architecture, aimed at maintaining the integrity and safety of deployed applications.

### Infrastructure Components

The infrastructure for CapsuleBay includes several key components defined in the `infra/docker-compose.yml` file:

- **Vault**: A HashiCorp Vault instance for managing secrets and sensitive data.
- **Docker Registry**: A private Docker registry for storing built images, secured with basic authentication.
- **Registry UI**: A user interface for managing the Docker registry.

These components work together to support the CI/CD processes, providing a secure environment for building and deploying applications. 

Overall, the CapsuleBay architecture leverages both GitHub Actions and Jenkins to create a robust CI/CD pipeline, ensuring efficient and secure software delivery.
