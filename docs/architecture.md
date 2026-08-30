# System Architecture

## CI/CD Architecture

The CapsuleBay repository employs a CI/CD architecture that integrates GitHub Actions and Jenkins to automate the build, test, and deployment processes.

### GitHub Actions

Two primary workflows are defined in the `.github/workflows` directory:

1. **CI.yml**: This workflow is triggered on push events to any branch and on pull requests. It consists of the following jobs:
   - **Checkout**: Uses the `actions/checkout@v4` action to pull the repository code.
   - **Set up Docker Buildx**: Utilizes `docker/setup-buildx-action@v3` to prepare the Docker Buildx environment.
   - **Build images**: Leverages `docker/build-push-action@v5` to build Docker images for the `whoami` service, tagging it as `capsulebay/whoami:test`.
   - **Security Scan (Trivy)**: Implements the `aquasecurity/trivy-action@master` to scan the built image for vulnerabilities, specifically looking for high and critical severity issues.

2. **snyk.yml**: This workflow is also triggered on push events, pull requests, and can be manually dispatched. It includes:
   - **Checkout code**: Similar to the CI.yml, it checks out the repository code.
   - **Set up Docker and Snyk**: Installs Snyk and authenticates using a secret token.
   - **Build and scan all Dockerfiles**: Searches for Dockerfiles in the repository, builds images from them, and runs Snyk to test for vulnerabilities, reporting any high severity issues.

### Jenkins

The Jenkins integration is defined in the `Jenkinsfile`, which is not detailed in the provided files but typically includes stages for building, testing, and deploying applications. The Jenkins setup is supported by a Docker registry configured in the `infra/docker-compose.yml`, which includes:

- **Registry Service**: A Docker registry that requires authentication via htpasswd, allowing for secure storage and retrieval of Docker images.
- **Vault Service**: A HashiCorp Vault instance for managing secrets and sensitive data.
- **Registry UI**: A user interface for managing the Docker registry.

### Summary

The CapsuleBay CI/CD architecture leverages GitHub Actions for continuous integration and security scanning, while Jenkins is set up for additional build and deployment tasks, supported by a Docker registry and Vault for secure image management and secret handling.
