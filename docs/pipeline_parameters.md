# Pipeline Parameters

This document explains the parameters used in the CapsuleBay pipeline, including options for service selection and deployment environments.

## Pipeline Parameters Overview

The CapsuleBay pipeline utilizes specific parameters to control the deployment process. Below is a detailed description of each parameter, including its options and purpose.

| Parameter   | Options                          | Description                                           |
|-------------|----------------------------------|-------------------------------------------------------|
| SERVICE     | `n8n`, `portainer`, `whoami`, `all` | Specifies which stack(s) to deploy.                   |
| ENVIRONMENT | `dev`, `staging`, `prod`        | Defines the target environment and corresponding Vault path. |
| RUN_TYPE    | `Deploy`, `Build and Deploy`     | Determines whether to rebuild the image or redeploy an existing one. |

## Detailed Parameter Descriptions

### SERVICE
- **Options**:
  - `n8n`: Deploys the n8n workflow automation tool.
  - `portainer`: Deploys the Portainer management UI for Docker.
  - `whoami`: Deploys a simple HTTP server for testing and debugging.
  - `all`: Deploys all available services.

### ENVIRONMENT
- **Options**:
  - `dev`: Targets the development environment.
  - `staging`: Targets the staging environment for pre-production testing.
  - `prod`: Targets the production environment for live deployment.

### RUN_TYPE
- **Options**:
  - `Deploy`: Deploys the specified service(s) without rebuilding the images.
  - `Build and Deploy`: Rebuilds the images and then deploys the specified service(s).

## Vault Integration Example

Secrets are managed using HashiCorp Vault and can be injected into the deployment process. Below is an example of how to set up secrets for the `n8n` service in the development environment:

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/n8n/dev N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=supersecret
vault kv get secret/n8n/dev
```

During deployment, these secrets are automatically injected into the `.env` file for the service.

## Example Capsule Configuration

### n8n/Dockerfile
```dockerfile
FROM docker:27.0.3-cli-alpine3.20
RUN apk add --no-cache docker-cli-compose bash
WORKDIR /app
COPY . /app
ARG LAN_IP
ENV LAN_IP=$LAN_IP
CMD ["docker", "compose", "up", "-d"]
```

### n8n/docker-compose.yml
```yaml
version: "3.9"
services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    env_file:
      - .env
```

## Security and Notifications

CapsuleBay integrates security checks at multiple stages of the pipeline. Notifications are sent via Discord at the end of each deployment, providing details such as service name, environment, build link, duration, and timestamp.

This structured approach ensures that each deployment is secure, traceable, and efficient, aligning with the overall goals of the CapsuleBay framework.
