# Pipeline Parameters

## Overview of Parameters

The CapsuleBay pipeline utilizes several parameters to control the deployment and build process. Below is a detailed description of each parameter, including the available options and their purposes.

| Parameter  | Options                        | Description                                                  |
|------------|--------------------------------|--------------------------------------------------------------|
| SERVICE    | `n8n`, `portainer`, `whoami`, `all` | Specifies which stack(s) to deploy. Use `all` to deploy all services. |
| ENVIRONMENT| `dev`, `staging`, `prod`      | Defines the target environment and the corresponding Vault path for secrets. |
| RUN_TYPE   | `Deploy`, `Build and Deploy`   | Determines the action to take: either to deploy an existing capsule or to build and deploy a new one. |

## Vault Example

To manage secrets, you can use the following commands to enable and store secrets in Vault:

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/n8n/dev N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=supersecret
vault kv get secret/n8n/dev
```

Secrets are automatically injected into each service's `.env` file during deployment.

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

## Security Stack

CapsuleBay incorporates multiple layers of security checks throughout the pipeline:

| Layer                      | Tool            | Purpose                                               |
|---------------------------|-----------------|-------------------------------------------------------|
| GitHub Actions (pre-merge)| Trivy           | Scans built images for vulnerabilities.               |
|                           | Snyk            | Scans Dockerfiles for dependency CVEs.                |
| Jenkins (pre-deploy)     | Trivy CLI       | Rescans the final image before deployment.            |
| Vault                     | HashiCorp Vault | Securely manages and delivers secrets.                |
| Discord                   | Webhook alerts   | Sends notifications about build success or failure.   |

## Discord Notifications

At the conclusion of each pipeline run, CapsuleBay sends a notification to Discord containing:

- Service name
- Environment
- Build link (e.g., `[Build #42](https://jenkins.example.local/job/CapsuleBay/42/)`)
- Duration
- Timestamp
- User ping (`<@UserID>`)

**Example Notification:**

> CapsuleBay Deployment Successful  
> Service: portainer  
> Environment: prod  
> Build: [#42](https://jenkins.example.local/job/CapsuleBay/42/)  
> Duration: 2m 34s  
> Timestamp: 2025-10-26 20:42  

This structured approach ensures that all necessary parameters are clearly defined and managed throughout the CapsuleBay CI/CD pipeline.
