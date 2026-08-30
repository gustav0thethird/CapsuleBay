# Getting Started

### 1. Deploy the Core Infrastructure
To set up the core infrastructure for CapsuleBay, navigate to the `infra` directory and run the setup script:

```bash
cd infra
sudo ./setup.sh
```

This script will:
- Automatically detect your LAN IP.
- Create a `.env` and `.secrets` file with generated credentials.
- Deploy Vault, Registry, and an optional Registry UI.

After running the setup, the following services will be available:

| Service      | Purpose                                   | URL                     |
|--------------|-------------------------------------------|-------------------------|
| Vault        | Secret storage for Jenkins & services     | `http://<LAN_IP>:8200` |
| Registry     | Local image registry                       | `http://<LAN_IP>:5000` |
| Registry UI  | Optional web dashboard                     | `http://<LAN_IP>:5001` |

### 2. Initialize Vault
After setting up the infrastructure, you need to initialize Vault:

```bash
docker exec -it vault vault operator init
docker exec -it vault vault operator unseal <key>
```

### 3. Repository Structure
The repository is organized as follows:

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

Each directory (except `infra/`) represents a self-contained capsule.

### 4. Adding a New Capsule
To add a new service, follow these steps:

1. Create a new folder, e.g., `myservice/`.
2. Add a `Dockerfile` and `docker-compose.yml` in that folder.
3. Update the Jenkins `SERVICE` parameter list to include the new folder name.

CapsuleBay will automatically handle the build, push, scan, and deployment processes for the new capsule.

### 5. Pipeline Parameters
When deploying, you can specify the following parameters:

| Parameter   | Options                          | Description                                   |
|-------------|----------------------------------|-----------------------------------------------|
| SERVICE     | `n8n`, `portainer`, `whoami`, `all` | Which stack(s) to deploy                     |
| ENVIRONMENT | `dev`, `staging`, `prod`        | Target environment and Vault path            |
| RUN_TYPE    | `Deploy`, `Build and Deploy`    | Choose whether to rebuild or redeploy only   |

### 6. Vault Example
To add secrets to Vault, use the following commands:

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/n8n/dev N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=supersecret
vault kv get secret/n8n/dev
```

Secrets will be automatically injected into each `.env` file during deployment.

### 7. Example Capsule
Here is an example of a simple capsule configuration:

**n8n/Dockerfile**
```dockerfile
FROM docker:27.0.3-cli-alpine3.20
RUN apk add --no-cache docker-cli-compose bash
WORKDIR /app
COPY . /app
ARG LAN_IP
ENV LAN_IP=$LAN_IP
CMD ["docker", "compose", "up", "-d"]
```

**n8n/docker-compose.yml**
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

### 8. Security Stack
CapsuleBay incorporates multiple layers of security checks:

| Layer                      | Tool                | Purpose                                      |
|---------------------------|---------------------|----------------------------------------------|
| GitHub Actions (pre-merge)| Trivy               | Scan built images for vulnerabilities        |
|                           | Snyk                | Scan Dockerfiles for dependency CVEs        |
| Jenkins (pre-deploy)      | Trivy CLI           | Rescan final image before deployment         |
| Vault                     | HashiCorp Vault     | Securely manage and deliver secrets          |
| Discord                   | Webhook alerts      | Send success or failure messages with build link |

### 9. Discord Notifications
At the end of each pipeline run, CapsuleBay sends a Discord notification containing:

- Service name
- Environment
- Build link (e.g., `[Build #42](https://jenkins.example.local/job/CapsuleBay/42/)`)
- Duration
- Timestamp
- User ping (`<@UserID>`)

This ensures that the team is informed about the deployment status.
