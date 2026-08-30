# Capsule Structure

This document outlines the structure and components of a capsule within the CapsuleBay repository, including details on the Dockerfile and docker-compose.yml files.

## Capsule Structure

Each capsule in CapsuleBay is organized with a specific directory structure that includes Dockerfiles and docker-compose.yml files for containerization and orchestration.

### Dockerfile

The Dockerfile is a script that contains a series of instructions on how to build a Docker image for the capsule. Each capsule has its own Dockerfile located in its respective directory. For example, the `whoami` capsule has the following Dockerfile:

```dockerfile
# Example Dockerfile for the whoami capsule
FROM alpine:latest
CMD ["echo", "Hello from whoami"]
```

This Dockerfile specifies that the image is based on the latest Alpine Linux and runs a simple command that outputs a message.

### docker-compose.yml

The docker-compose.yml file is used to define and run multi-container Docker applications. In the CapsuleBay repository, the `infra/docker-compose.yml` file is structured as follows:

```yaml
version: "3.9"

name: infra

services:
  vault:
    image: hashicorp/vault:1.15.4
    container_name: vault
    ports:
      - "8200:8200"
      - "8201:8201"
    cap_add:
      - IPC_LOCK
    environment:
      - LAN_IP=${LAN_IP}
    volumes:
      - ./data/vault:/vault/file
      - ./vault.hcl:/vault/config/vault.hcl:ro
    command: ["vault", "server", "-config=/vault/config/vault.hcl"]
    restart: unless-stopped
    networks: [infra]

  htpasswd:
    image: httpd:alpine
    container_name: htpasswd-generator
    entrypoint: >
      sh -c "mkdir -p /auth && \
             htpasswd -Bbn jenkins jenkinspass > /auth/htpasswd"
    volumes:
      - ./data/auth:/auth
    restart: "no"
    networks: [infra]

  registry:
    image: registry:2.8.3
    depends_on:
      htpasswd:
        condition: service_completed_successfully
    container_name: docker-registry
    ports:
      - "${LAN_IP}:5000:5000"
    environment:
      REGISTRY_HTTP_ADDR: :5000
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
    volumes:
      - ./data/registry:/var/lib/registry
      - ./data/auth:/auth:ro
      - ./data/registry/config.yml:/etc/docker/registry/config.yml:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/v2/"]
      interval: 15s
      timeout: 5s
      retries: 10
    restart: unless-stopped
    networks: [infra]

  registry-ui:
    image: joxit/docker-registry-ui:2.5.0
    container_name: docker-registry-ui
    ports:
      - "${LAN_IP}:5001:80"
    environment:
      - REGISTRY_TITLE=${REGISTRY_TITLE}
      - REGISTRY_URL=http://${LAN_IP}:5000
      - DELETE_IMAGES=true
    depends_on:
      - registry
    restart: unless-stopped
    networks: [infra]

networks:
  infra:
    driver: bridge
```

#### Key Components

- **Services**: Each service (e.g., vault, htpasswd, registry, registry-ui) is defined with its own configuration, including the image to use, ports to expose, environment variables, and volumes for persistent storage.
- **Networks**: The `infra` network is defined to allow communication between the services.

### CI/CD Integration

The repository includes CI/CD configurations in `.github/workflows/CI.yml` and `.github/workflows/snyk.yml` for building and scanning Docker images. These workflows ensure that images are built and scanned for vulnerabilities upon code changes.

### Conclusion

The structure of a capsule in CapsuleBay is designed to facilitate easy deployment and management of services using Docker. Each capsule's Dockerfile and docker-compose.yml play crucial roles in defining how the services are built and orchestrated.
