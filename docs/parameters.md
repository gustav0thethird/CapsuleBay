# Pipeline Parameters

This document outlines the parameters used in the CI/CD pipeline for deployment in the CapsuleBay repository.

## GitHub Actions CI Workflow Parameters

### CI.yml

- **on**: Specifies the events that trigger the workflow.
  - **push**: Triggers on pushes to any branch.
  - **pull_request**: Triggers on pull requests.

- **jobs**: Defines the jobs that will run as part of the workflow.
  - **build**: The job responsible for building the application.
    - **runs-on**: Specifies the environment for the job (e.g., `ubuntu-latest`).
    - **steps**: A sequence of steps to execute.
      - **Checkout**: Uses `actions/checkout@v4` to check out the repository.
      - **Set up Docker Buildx**: Uses `docker/setup-buildx-action@v3` to set up Docker Buildx.
      - **Build images**: Uses `docker/build-push-action@v5` to build Docker images.
        - **context**: Path to the Docker context (e.g., `./whoami`).
        - **tags**: Tags for the built image (e.g., `capsulebay/whoami:test`).
        - **load**: Indicates whether to load the image into the local Docker daemon.
      - **Security Scan (Trivy)**: Uses `aquasecurity/trivy-action@master` to perform a security scan.
        - **image-ref**: Reference to the image to scan (e.g., `capsulebay/whoami:test`).
        - **format**: Output format for the scan results (e.g., `table`).
        - **severity**: Specifies the severity levels to report (e.g., `HIGH,CRITICAL`).

### Snyk Workflow Parameters

### snyk.yml

- **on**: Specifies the events that trigger the workflow.
  - **push**: Triggers on pushes to any branch.
  - **pull_request**: Triggers on pull requests.
  - **workflow_dispatch**: Allows manual triggering of the workflow.

- **jobs**: Defines the jobs that will run as part of the workflow.
  - **snyk-scan**: The job responsible for scanning Dockerfiles.
    - **runs-on**: Specifies the environment for the job (e.g., `ubuntu-latest`).
    - **steps**: A sequence of steps to execute.
      - **Checkout code**: Uses `actions/checkout@v4` to check out the repository.
      - **Set up Docker and Snyk**: Installs Snyk and authenticates using a secret token.
        - **snyk auth**: Uses `${{ secrets.SNYK_TOKEN }}` for authentication.
      - **Build and scan all Dockerfiles**: A script that finds and scans all Dockerfiles.
        - **find**: Searches for Dockerfiles in the repository.
        - **docker build**: Builds the Docker image for each Dockerfile found.
        - **snyk container test**: Tests the built image for vulnerabilities.

## GitLab CI Parameters

### .gitlab-ci.yml

- **include**: Specifies external CI templates to include.
  - **project**: The project from which to include templates (e.g., `yditj/ci-templates`).
  - **file**: The specific template files to include (e.g., `ai-docs.yml`, `mirror.yml`).

## Jenkinsfile Parameters

- The Jenkinsfile is not detailed in the provided sources. Please refer to the Jenkins documentation for specific parameters used in Jenkins pipelines.

## Docker Compose Parameters

### infra/docker-compose.yml

- **version**: Specifies the version of the Docker Compose file format.
- **services**: Defines the services that will be run.
  - **vault**: Configuration for the Vault service.
    - **image**: Docker image to use (e.g., `hashicorp/vault:1.15.4`).
    - **container_name**: Name of the container (e.g., `vault`).
    - **ports**: Ports to expose (e.g., `8200:8200`).
    - **environment**: Environment variables for the service (e.g., `LAN_IP=${LAN_IP}`).
    - **volumes**: Mounts for persistent storage.
    - **command**: Command to run the service.
    - **restart**: Restart policy (e.g., `unless-stopped`).
    - **networks**: Networks to which the service belongs.

  - **htpasswd**: Configuration for the htpasswd generator service.
    - **image**: Docker image to use (e.g., `httpd:alpine`).
    - **entrypoint**: Command to generate htpasswd file.
    - **volumes**: Mounts for persistent storage.
    - **restart**: Restart policy.

  - **registry**: Configuration for the Docker registry service.
    - **image**: Docker image to use (e.g., `registry:2.8.3`).
    - **depends_on**: Specifies dependencies for the service.
    - **container_name**: Name of the container (e.g., `docker-registry`).
    - **ports**: Ports to expose (e.g., `${LAN_IP}:5000:5000`).
    - **environment**: Environment variables for the service.
    - **volumes**: Mounts for persistent storage.
    - **healthcheck**: Health check configuration.
    - **restart**: Restart policy.

  - **registry-ui**: Configuration for the Docker registry UI service.
    - **image**: Docker image to use (e.g., `joxit/docker-registry-ui:2.5.0`).
    - **container_name**: Name of the container (e.g., `docker-registry-ui`).
    - **ports**: Ports to expose (e.g., `${LAN_IP}:5001:80`).
    - **environment**: Environment variables for the service.
    - **depends_on**: Specifies dependencies for the service.
    - **restart**: Restart policy.

## Conclusion

This document provides an overview of the parameters used in the CI/CD pipeline for the CapsuleBay repository. For further details, refer to the respective configuration files.
