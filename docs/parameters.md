# Pipeline Parameters

This document describes the parameters used in the CI/CD pipeline for deployment in the CapsuleBay repository.

## CI Workflow Parameters

### General Parameters

- **on**: Specifies the events that trigger the workflow.
  - **push**: Triggers the workflow on push events to any branch.
  - **pull_request**: Triggers the workflow on pull request events.

### Jobs

#### Build Job

- **runs-on**: Specifies the type of runner that the job will run on. In this case, it is set to `ubuntu-latest`.

##### Steps

1. **Checkout**
   - **uses**: `actions/checkout@v4`
   - Checks out the repository code.

2. **Set up Docker Buildx**
   - **uses**: `docker/setup-buildx-action@v3`
   - Sets up Docker Buildx for building multi-platform images.

3. **Build images (for validation)**
   - **uses**: `docker/build-push-action@v5`
   - **with**:
     - **context**: `./whoami`
     - **tags**: `capsulebay/whoami:test`
     - **load**: `true`
   - Builds the Docker image for the `whoami` service.

4. **Security Scan (Trivy)**
   - **uses**: `aquasecurity/trivy-action@master`
   - **with**:
     - **image-ref**: `capsulebay/whoami:test`
     - **format**: `table`
     - **severity**: `HIGH,CRITICAL`
   - Scans the built image for vulnerabilities.

#### Snyk Scan Job

- **runs-on**: Specifies the runner type as `ubuntu-latest`.

##### Steps

1. **Checkout code**
   - **uses**: `actions/checkout@v4`
   - Checks out the repository code.

2. **Set up Docker and Snyk**
   - **run**: 
     - Updates the package list and installs Snyk.
     - Authenticates Snyk using the secret token `${{ secrets.SNYK_TOKEN }}`.

3. **Build and scan all Dockerfiles**
   - **run**: 
     - Searches for Dockerfiles in the repository.
     - Builds each Dockerfile found and scans it using Snyk.
     - **image_name**: Constructed from the directory name of the Dockerfile.
     - **severity-threshold**: Set to `high` to filter results.

## GitLab CI Parameters

### Include

- **include**: Specifies external CI templates to include.
  - **project**: `yditj/ci-templates`
  - **file**: `ai-docs.yml` and `mirror.yml`

## Environment Variables

### Docker Compose Parameters

- **LAN_IP**: The local area network IP address, defaults to the first IP address of the host.
- **REGISTRY_TITLE**: Title for the local Docker registry, defaults to "Local Registry".
- **JENKINS_USER**: Username for Jenkins, defaults to "jenkins".
- **JENKINS_PASS**: Password for Jenkins, generated if not provided.

### Vault Configuration

- **VAULT_PORT**: Port for the Vault service, set to `8200`.
- **REGISTRY_PORT**: Port for the Docker registry, set to `5000`.
- **REGISTRY_UI_PORT**: Port for the Docker registry UI, set to `5001`.

## Healthcheck Parameters

- **healthcheck**: Defines the health check for the Docker registry.
  - **test**: Command to check the health of the registry.
  - **interval**: Time between health checks, set to `15s`.
  - **timeout**: Time to wait for a health check to succeed, set to `5s`.
  - **retries**: Number of retries before marking the service as unhealthy, set to `10`.
