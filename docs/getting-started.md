# Getting Started

This guide provides a step-by-step process for deploying the core infrastructure and initializing services for CapsuleBay.

## Prerequisites

Ensure you have the following installed on your machine:

- Docker
- Docker Compose
- Curl
- OpenSSL

## Step 1: Clone the Repository

Clone the CapsuleBay repository to your local machine:

```bash
git clone https://github.com/gustav0thethird/CapsuleBay.git
cd CapsuleBay
```

## Step 2: Set Up Environment Variables

Create a `.env` file in the `infra` directory to define necessary environment variables:

```bash
cd infra
cat > .env <<EOF
LAN_IP=$(hostname -I | awk '{print $1}')
REGISTRY_TITLE=Local Registry
JENKINS_USER=jenkins
JENKINS_PASS=$(openssl rand -hex 16)
EOF
```

## Step 3: Run the Setup Script

Execute the `setup.sh` script to initialize the infrastructure:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:

- Create necessary directories for Vault, Registry, and authentication.
- Generate a Vault configuration file.
- Create a Docker Compose file for the infrastructure.
- Save Jenkins credentials securely.

## Step 4: Start the Services

Use Docker Compose to start the services defined in `docker-compose.yml`:

```bash
docker-compose up -d
```

This command will start the following services:

- **Vault**: A tool for securely accessing secrets.
- **Docker Registry**: A private registry for storing Docker images.
- **Registry UI**: A user interface for managing the Docker Registry.
- **Htpasswd Generator**: A service to create a password file for registry authentication.

## Step 5: Verify the Services

Check the status of the running services:

```bash
docker-compose ps
```

You should see the services listed as running. You can access the Vault UI at `http://<LAN_IP>:8200` and the Docker Registry UI at `http://<LAN_IP>:5001`.

## Step 6: Initialize Vault

To initialize Vault, run the following command:

```bash
docker exec -it vault vault operator init
```

Follow the instructions to save the unseal keys and the root token securely.

## Step 7: Unseal Vault

Use the unseal keys obtained from the initialization step to unseal Vault:

```bash
docker exec -it vault vault operator unseal <unseal_key_1>
docker exec -it vault vault operator unseal <unseal_key_2>
docker exec -it vault vault operator unseal <unseal_key_3>
```

## Step 8: Login to Vault

Log in to Vault using the root token:

```bash
docker exec -it vault vault login <root_token>
```

## Conclusion

You have successfully deployed the core infrastructure for CapsuleBay and initialized the services. You can now proceed to configure and use the services as needed.
