# CI/CD Pipeline

## Overview

The CI/CD pipeline for the CapsuleBay repository is designed to automate the build and scanning processes for Docker images. It utilizes GitHub Actions for continuous integration and deployment, ensuring that code changes are validated and security vulnerabilities are identified promptly.

### Build Process

The build process is defined in the `.github/workflows/CI.yml` file. It triggers on any push to branches or pull requests. The key steps involved are:

1. **Checkout Code**: The pipeline starts by checking out the code from the repository using the `actions/checkout@v4` action.
   
2. **Set Up Docker Buildx**: The pipeline sets up Docker Buildx, which is a Docker CLI plugin for extended build capabilities with BuildKit.

3. **Build Images**: The Docker image for the `whoami` service is built using the `docker/build-push-action@v5`. The image is tagged as `capsulebay/whoami:test` and is loaded into the local Docker daemon for further processing.

### Security Scan

After the build process, a security scan is performed using Trivy, as specified in the same `.github/workflows/CI.yml` file:

1. **Security Scan (Trivy)**: The `aquasecurity/trivy-action@master` is used to scan the built image (`capsulebay/whoami:test`) for vulnerabilities. The scan focuses on high and critical severity issues, presenting the results in a table format.

### Additional Scanning

In addition to the primary CI workflow, a separate workflow for scanning Dockerfiles is defined in `.github/workflows/snyk.yml`. This workflow also triggers on pushes, pull requests, and can be manually initiated. The steps include:

1. **Checkout Code**: Similar to the CI workflow, it checks out the code using `actions/checkout@v4`.

2. **Set Up Docker and Snyk**: The workflow installs Snyk, a tool for identifying vulnerabilities in Docker images, and authenticates using a secret token.

3. **Build and Scan Dockerfiles**: The workflow searches for Dockerfiles in the repository, builds each Dockerfile into an image, and scans it using Snyk. The results are filtered to show only high severity vulnerabilities. Each scan is executed in a loop for all found Dockerfiles.

### Summary

The CapsuleBay CI/CD pipeline effectively integrates build and security scanning processes to maintain code quality and security. The use of GitHub Actions allows for seamless automation, ensuring that any changes made to the codebase are continuously validated against potential vulnerabilities.
