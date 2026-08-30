# Getting Started

### 1. Deploy the Core Infrastructure
To set up the core infrastructure required for CapsuleBay, follow these steps:

```bash
cd infra
sudo ./setup.sh
```

This script performs the following actions:
- Automatically detects your LAN IP.
- Creates a `.env` and `.secrets` file with generated credentials.
- Deploys Vault, a local Docker registry, and an optional Registry UI.

After running the setup, you will have the following services available:

| Service      | Purpose                                   | URL                     |
|--------------|-------------------------------------------|-------------------------|
| Vault        | Secret storage for Jenkins & services     | `http://<LAN_IP>:8200` |
| Registry     | Local image registry                       | `http://<LAN_IP>:5000` |
| Registry UI  | Optional web dashboard for the registry    | `http://<LAN_IP>:5001` |

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

CapsuleBay will automatically handle:
- Building and pushing the capsule image.
- Scanning for vulnerabilities.
- Retrieving secrets from Vault.
- Deploying the capsule remotely on the correct VM.

### 5. Vault Example
To store secrets in Vault, use the following commands:

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/n8n/dev N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=supersecret
vault kv get secret/n8n/dev
```

Secrets are automatically injected into each `.env` file during deployment.

### 6. Security Stack
CapsuleBay integrates multiple layers of security checks:

| Layer                       | Tool                | Purpose                                      |
|----------------------------|---------------------|----------------------------------------------|
| GitHub Actions (pre-merge) | Trivy               | Scan built images for vulnerabilities        |
|                            | Snyk                | Scan Dockerfiles for dependency CVEs         |
| Jenkins (pre-deploy)       | Trivy CLI           | Rescan final image before deployment         |
| Vault                      | HashiCorp Vault     | Securely manage and deliver secrets          |
| Discord                    | Webhook alerts      | Send success or failure messages with build link |

### 7. Discord Notifications
At the end of each pipeline run, CapsuleBay sends a Discord notification containing:
- Service name
- Environment
- Build link (e.g., `[Build #42](https://jenkins.example.local/job/CapsuleBay/42/)`)
- Duration
- Timestamp
- User ping (`<@UserID>`)

### 8. Example Capsule
Here is an example of a simple capsule setup:

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

### Conclusion
By following these steps, you will have the core infrastructure for CapsuleBay deployed and ready for use. You can then proceed to add new capsules and manage your CI/CD pipelines effectively.
