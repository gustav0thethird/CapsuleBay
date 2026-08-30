# Managing Capsules

## Overview

CapsuleBay utilizes a modular architecture where each service is encapsulated in its own directory, functioning as a self-contained deployment unit. Each capsule includes its own `Dockerfile` and `docker-compose.yml`, ensuring no dependencies on external scripts or the repository's Git state.

## Adding a New Capsule

To add a new service (capsule) to CapsuleBay, follow these steps:

1. **Create a Folder**: Create a new directory for your service, e.g., `myservice/`.
2. **Add Required Files**:
   - **Dockerfile**: This file defines how to build the Docker image for your service.
   - **docker-compose.yml**: This file specifies the services, networks, and volumes required for your application.

3. **Update Jenkins Configuration**: Add the name of your new folder to the `SERVICE` parameter list in the Jenkins configuration. This allows Jenkins to recognize and manage the new capsule.

Once these steps are completed, CapsuleBay will automatically handle the following processes:
- Build and push the capsule image.
- Scan the image for vulnerabilities.
- Retrieve secrets from Vault.
- Deploy the capsule remotely on the appropriate VM.

No additional pipeline edits or scripts are necessary.

## Folder Structure

The folder structure for each capsule should resemble the following:

```
myservice/
├── Dockerfile
└── docker-compose.yml
```

## Dockerfile Requirements

Your `Dockerfile` should include the necessary instructions to build the image for your service. Here is a basic example:

```dockerfile
FROM <base-image>
# Install dependencies
RUN <install-commands>
WORKDIR /app
COPY . /app
CMD ["<command-to-start-service>"]
```

### Example Dockerfile

```dockerfile
FROM docker:27.0.3-cli-alpine3.20
RUN apk add --no-cache docker-cli-compose bash
WORKDIR /app
COPY . /app
ARG LAN_IP
ENV LAN_IP=$LAN_IP
CMD ["docker", "compose", "up", "-d"]
```

## docker-compose.yml Requirements

The `docker-compose.yml` file should define the services, networks, and volumes required for your application. Ensure that it includes the necessary environment variables and ports.

### Example docker-compose.yml

```yaml
version: "3.9"
services:
  myservice:
    image: myservice:latest
    ports:
      - "8080:8080"
    env_file:
      - .env
```

## Pipeline Parameters

When adding a new capsule, ensure the following parameters are set in Jenkins:

| Parameter   | Options                          | Description                                       |
|-------------|----------------------------------|---------------------------------------------------|
| SERVICE     | `myservice`, `all`              | Which stack(s) to deploy                          |
| ENVIRONMENT | `dev`, `staging`, `prod`        | Target environment and Vault path                 |
| RUN_TYPE    | `Deploy`, `Build and Deploy`    | Choose whether to rebuild or redeploy only        |

## Vault Configuration

For each new service, you may need to configure secrets in Vault. Use the following commands to enable and store secrets:

```bash
vault secrets enable -path=secret kv-v2
vault kv put secret/myservice/dev MY_SECRET_KEY=mysecretvalue
vault kv get secret/myservice/dev
```

Secrets will be automatically injected into the `.env` file during deployment.

## Conclusion

By following these guidelines, you can efficiently add new capsules to the CapsuleBay framework. Ensure that each capsule is self-contained with its own `Dockerfile` and `docker-compose.yml`, and update the Jenkins configuration accordingly. This modular approach facilitates streamlined builds, scans, and deployments.
