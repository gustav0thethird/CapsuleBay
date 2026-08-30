# Capsule Structure

This document outlines the structure and components of a capsule within the CapsuleBay repository, including details on the `Dockerfile` and `docker-compose.yml` files.

## Capsule Components

A capsule in CapsuleBay is composed of several key components that facilitate modular, image-based deployments. Each capsule typically includes a `Dockerfile` for building the container image and a `docker-compose.yml` file for orchestrating the deployment of services.

### Dockerfile

The `Dockerfile` defines the environment for the application. It specifies the base image, dependencies, and commands to run the application. Each capsule may have its own `Dockerfile` located in its respective directory. 

For example, the `whoami` capsule includes a `Dockerfile` that sets up a simple web service. The contents of the `Dockerfile` typically include:

- Base image declaration
- Installation of necessary packages
- Copying application files into the image
- Setting environment variables
- Specifying the command to run the application

### docker-compose.yml

The `docker-compose.yml` file is used to define and run multi-container Docker applications. This file specifies the services, networks, and volumes required for the capsule. 

An example `docker-compose.yml` for the infrastructure components is as follows:

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

### Summary

Each capsule in CapsuleBay is structured to include a `Dockerfile` for building its image and a `docker-compose.yml` file for managing its services. This modular approach allows for flexible and secure deployments, leveraging Docker's capabilities for containerization and orchestration.
