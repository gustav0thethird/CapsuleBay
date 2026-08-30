# Getting Started

This guide provides a step-by-step process to deploy the core infrastructure and initialize services for CapsuleBay.

## Prerequisites

Ensure you have the following installed on your system:

- Docker
- Curl
- OpenSSL

## Step 1: Clone the Repository

Clone the CapsuleBay repository to your local machine:

```bash
git clone https://github.com/gustav0thethird/CapsuleBay.git
cd CapsuleBay
```

## Step 2: Set Up Environment Variables

Before running the setup script, you may want to customize the environment variables. You can set the following variables in your shell or modify the `setup.sh` script:

- `BASE_DIR`: Directory for infrastructure files (default: `/opt/infra`)
- `LAN_IP`: Local IP address (default: detected automatically)
- `REGISTRY_TITLE`: Title for the Docker registry (default: `Local Registry`)
- `JENKINS_USER`: Username for Jenkins (default: `jenkins`)
- `JENKINS_PASS`: Password for Jenkins (default: randomly generated)

## Step 3: Run the Setup Script

Execute the setup script to initialize the infrastructure:

```bash
bash infra/setup.sh
```

This script will:

1. Create necessary directories for Vault, Docker registry, and authentication.
2. Generate a Vault configuration file.
3. Create a `.env` file with environment variables.
4. Save Jenkins credentials securely in a `.secrets` file.

## Step 4: Start the Services

Navigate to the `infra` directory and start the services using Docker Compose:

```bash
cd infra
docker-compose up -d
```

This command will start the following services:

- **Vault**: A tool for securely accessing secrets.
- **Docker Registry**: A private registry for storing Docker images.
- **Registry UI**: A web interface for managing the Docker registry.
- **Htpasswd Generator**: A service to generate htpasswd files for authentication.

## Step 5: Verify the Services

After starting the services, verify that they are running correctly:

- Vault should be accessible at `http://<LAN_IP>:8200`
- Docker Registry should be accessible at `http://<LAN_IP>:5000`
- Registry UI should be accessible at `http://<LAN_IP>:5001`

You can check the status of the services with:

```bash
docker-compose ps
```

## Step 6: Accessing Vault

To interact with Vault, you can use the Vault CLI or the web UI. Ensure you initialize and unseal Vault before using it.

## Step 7: Stopping the Services

To stop the services, run:

```bash
docker-compose down
```

This command will stop and remove the containers created by Docker Compose.

## Conclusion

You have successfully deployed the core infrastructure for CapsuleBay. You can now proceed to configure and use the services as needed.
