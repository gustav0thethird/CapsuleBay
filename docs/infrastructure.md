# Infrastructure Setup

This document provides instructions for deploying the core infrastructure components of CapsuleBay, specifically Vault and the Docker Registry.

## Prerequisites

Ensure that the following dependencies are installed on your system:

- Docker
- Curl
- OpenSSL

## Setup Instructions

1. **Clone the Repository**

   Clone the CapsuleBay repository to your local machine:

   ```bash
   git clone <repository-url>
   cd CapsuleBay
   ```

2. **Run the Setup Script**

   Execute the `setup.sh` script to initialize the infrastructure components. This script will create necessary directories and configuration files.

   ```bash
   chmod +x infra/setup.sh
   infra/setup.sh
   ```

   The script will automatically detect your LAN IP and create the following directories:

   - `data/vault`
   - `data/registry`
   - `data/auth`

3. **Docker Compose Configuration**

   The `docker-compose.yml` file is configured to deploy the following services:

   - **Vault**: A tool for securely accessing secrets.
   - **Registry**: A Docker registry for storing and managing Docker images.
   - **Registry UI**: A user interface for the Docker registry.
   - **Htpasswd**: A service for generating a password file for registry authentication.

   The relevant configuration for each service is as follows:

   ### Vault

   - **Image**: `hashicorp/vault:1.15.4`
   - **Ports**: 
     - `8200:8200` (API)
     - `8201:8201` (UI)
   - **Volumes**: 
     - `./data/vault:/vault/file`
     - `./vault.hcl:/vault/config/vault.hcl:ro`
   - **Command**: 
     ```bash
     vault server -config=/vault/config/vault.hcl
     ```

   ### Registry

   - **Image**: `registry:2.8.3`
   - **Ports**: 
     - `${LAN_IP}:5000:5000`
   - **Volumes**: 
     - `./data/registry:/var/lib/registry`
     - `./data/auth:/auth:ro`
     - `./data/registry/config.yml:/etc/docker/registry/config.yml:ro`
   - **Healthcheck**: 
     ```bash
     CMD curl -f http://localhost:5000/v2/
     ```

   ### Registry UI

   - **Image**: `joxit/docker-registry-ui:2.5.0`
   - **Ports**: 
     - `${LAN_IP}:5001:80`
   - **Environment Variables**: 
     - `REGISTRY_TITLE=${REGISTRY_TITLE}`
     - `REGISTRY_URL=http://${LAN_IP}:5000`
     - `DELETE_IMAGES=true`

4. **Start the Services**

   Use Docker Compose to start the services defined in the `docker-compose.yml` file:

   ```bash
   docker-compose -f infra/docker-compose.yml up -d
   ```

5. **Access the Services**

   - **Vault UI**: Access the Vault UI at `http://<LAN_IP>:8200`.
   - **Docker Registry**: Access the Docker Registry at `http://<LAN_IP>:5000`.
   - **Registry UI**: Access the Registry UI at `http://<LAN_IP>:5001`.

6. **Stopping the Services**

   To stop the services, run:

   ```bash
   docker-compose -f infra/docker-compose.yml down
   ```

## Conclusion

You have successfully set up the core infrastructure components for CapsuleBay. Ensure to manage your secrets and configurations securely.
