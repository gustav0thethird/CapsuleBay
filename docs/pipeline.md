# CI/CD Pipeline

## Overview

The CI/CD pipeline for the CapsuleBay repository is designed to automate the build and scanning processes for Docker images. It utilizes GitHub Actions and GitLab CI to ensure that code changes are validated and security vulnerabilities are identified before deployment.

### Build Process

The build process is primarily handled by the GitHub Actions workflow defined in `.github/workflows/CI.yml`. This workflow is triggered on pushes to any branch and on pull requests. The key steps in the build process include:

1. **Checkout Code**: The workflow begins by checking out the code from the repository using the `actions/checkout@v4` action.

2. **Set up Docker Buildx**: The Docker Buildx is set up to enable building multi-platform images.

3. **Build Images**: The Docker images are built using the `docker/build-push-action@v5`. For validation, the image for the `whoami` service is built and tagged as `capsulebay/whoami:test`.

### Security Scan

After the build process, a security scan is performed using Trivy, as specified in the same GitHub Actions workflow. The steps for the security scan include:

1. **Security Scan (Trivy)**: The `aquasecurity/trivy-action@master` is used to scan the built image (`capsulebay/whoami:test`) for vulnerabilities. The scan focuses on high and critical severity issues, and the results are displayed in a table format.

### Additional Scanning

In addition to the primary CI workflow, a separate GitHub Actions workflow for Snyk scanning is defined in `.github/workflows/snyk.yml`. This workflow is also triggered on pushes, pull requests, and can be manually initiated. The steps include:

1. **Checkout Code**: Similar to the CI workflow, the code is checked out using `actions/checkout@v4`.

2. **Set up Docker and Snyk**: The workflow installs Snyk and authenticates using a secret token.

3. **Build and Scan Dockerfiles**: The workflow searches for all Dockerfiles in the repository, builds each one, and performs a Snyk scan. The results are reported, focusing on vulnerabilities with a severity threshold of high or above.

### GitLab CI Integration

The repository also includes a GitLab CI configuration in `.gitlab-ci.yml`, which standardizes the CI process. This configuration includes references to external templates for AI documentation and GitHub mirroring, ensuring consistency across CI/CD practices.

### Summary

The CapsuleBay CI/CD pipeline effectively integrates build and security scanning processes using GitHub Actions and GitLab CI. This setup helps maintain code quality and security by automating the validation of Docker images before deployment.
