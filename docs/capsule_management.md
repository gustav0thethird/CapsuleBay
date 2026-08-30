# Managing Capsules

## Overview

CapsuleBay allows you to add new capsules easily, following a structured approach. Each capsule is a self-contained deployment unit, encapsulating its own Dockerfile and docker-compose.yml. This document outlines the guidelines for adding new capsules, including the necessary folder structure and files.

## Folder Structure

When adding a new capsule, create a new directory within the root of the repository. The structure should resemble the following:

```
.
└── myservice/
    ├── Dockerfile
    └── docker-compose.yml
```

### Directory Naming

- The directory name should be descriptive of the service it contains (e.g., `myservice`).

## Necessary Files

### 1. Dockerfile

The `Dockerfile` defines how to build the capsule image. It should include all necessary instructions to set up the environment for the service. Here is a basic example:

```dockerfile
FROM <base-image>
# Install dependencies
RUN <install-commands>
# Set working directory
WORKDIR /app
# Copy application files
COPY . /app
# Define command to run the service
CMD ["<command-to-start-service>"]
```

### 2. docker-compose.yml

The `docker-compose.yml` file specifies how to run the service, including its dependencies and configurations. A sample structure is as follows:

```yaml
version: "3.9"
services:
  myservice:
    image: <image-name>:<tag>
    ports:
      - "<host-port>:<container-port>"
    env_file:
      - .env
```

### 3. Environment Variables

If your service requires environment variables, create a `.env` file in the capsule directory. This file will be automatically injected during deployment. An example `.env` file might look like this:

```
MY_ENV_VAR=value
ANOTHER_ENV_VAR=another_value
```

## Updating the Pipeline

After creating the new capsule, you need to update the Jenkins pipeline to include the new service. This is done by adding the folder name to the `SERVICE` parameter list in the Jenkinsfile.

## Automated Processes

Once the new capsule is added and the pipeline is updated, CapsuleBay will automatically handle the following:

- Build and push the capsule image.
- Scan the image for vulnerabilities.
- Retrieve secrets from Vault.
- Deploy the capsule remotely on the appropriate VM.

No additional scripts or manual pipeline edits are required.

## Example Capsule

To illustrate, here’s a complete example of a new capsule named `myservice`.

**myservice/Dockerfile**
```dockerfile
FROM node:14
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

**myservice/docker-compose.yml**
```yaml
version: "3.9"
services:
  myservice:
    image: myservice:latest
    ports:
      - "3000:3000"
    env_file:
      - .env
```

**myservice/.env**
```
NODE_ENV=production
API_KEY=your_api_key
```

## Conclusion

By following these guidelines, you can efficiently add new capsules to CapsuleBay. Ensure that the folder structure is maintained, and the necessary files are included for a smooth integration into the CI/CD pipeline.
