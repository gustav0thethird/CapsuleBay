# Infrastructure Setup

This document provides instructions for deploying the core infrastructure components of CapsuleBay, including Vault and Docker Registry.

## Prerequisites

Ensure that the following dependencies are installed on your system:

- Docker
- Curl
- OpenSSL

## Directory Structure

The infrastructure components will be set up in the following directory structure:

```
/opt/infra
├── data
│   ├── auth
│   ├── registry
│   └── vault
└── vault.hcl
```

## Setup Instructions

1. **Clone the Repository**

   Clone the CapsuleBay repository to your local machine.

   ```bash
   git clone <repository-url>
   cd CapsuleBay
   ```

2. **Run the Setup Script**

   Execute the `setup.sh` script to initialize the infrastructure components.

   ```bash
   chmod +x infra/setup.sh
   infra/setup.sh
   ```

   This script will:
   - Create necessary directories.
   - Generate a Vault configuration file (`vault.hcl`).
   - Create a `.env` file with environment variables.
   - Generate a `.secrets` file to store Jenkins credentials securely.

3. **Deploy Infrastructure with Docker Compose**

   Navigate to the `infra` directory and run Docker Compose to start the services.

   ```bash
   cd infra
   docker-compose up -d
   ```

   This command will start the following services:

   - **Vault**
     - Port: `8200`
     - Configuration file: `vault.hcl`
     - Data storage: `./data/vault`

   - **Docker Registry**
     - Port: `5000`
     - Authentication: htpasswd
     - Data storage: `./data/registry`
     - Configuration file: `./data/registry/config.yml`

   - **Registry UI**
     - Port: `5001`
     - Connects to the Docker Registry.

4. **Accessing the Services**

   - Vault UI: [http://<LAN_IP>:8200](http://<LAN_IP>:8200)
   - Docker Registry: [http://<LAN_IP>:5000](http://<LAN_IP>:5000)
   - Registry UI: [http://<LAN_IP>:5001](http://<LAN_IP>:5001)

## Health Checks

The Docker Registry service includes a health check to ensure it is running correctly. You can verify the health status using:

```bash
docker inspect --format='{{json .State.Health}}' docker-registry
```

## Stopping the Services

To stop the running services, execute:

```bash
docker-compose down
```

This command will stop and remove the containers defined in the `docker-compose.yml` file.

## Conclusion

You have successfully set up the core infrastructure components for CapsuleBay. For further configurations or troubleshooting, refer to the respective service documentation.
