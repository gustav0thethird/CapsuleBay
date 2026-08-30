# System Architecture

CapsuleBay is structured around a two-layer CI/CD architecture that integrates both cloud-based and self-hosted components to facilitate modular, image-based deployments.

## 1. GitHub Actions – Cloud Validation Layer

This layer operates automatically on every push or pull request to ensure code integrity and security before deployment:

- **Builds Capsule Images**: Each service's Docker image is built for validation.
- **Trivy Image Scans**: Conducts security scans focusing on HIGH and CRITICAL vulnerabilities.
- **Snyk Dockerfile Scans**: Analyzes Dockerfiles for dependency-level vulnerabilities.
- **Artifact Uploads**: Scan reports are uploaded as artifacts for review.

This layer ensures that all commits are secure, compliant, and buildable prior to reaching the Jenkins deployment layer.

## 2. Jenkins – Self-Hosted Deployment Layer

The Jenkins layer manages controlled deployments within a local area network (LAN), utilizing Vault for secure secret management:

- **Builds, Tags, and Pushes Capsule Images**: Capsule images are built and pushed to a local registry.
- **Dynamic Secret Retrieval**: Secrets are fetched from Vault dynamically during the deployment process.
- **VM Lifecycle Management**: Ensures that the target virtual machine (VM) is powered on using the Proxmox API.
- **Final Image Scans**: Conducts a secondary scan of the built images using Trivy.
- **Remote Deployments**: Deploys the capsules using the embedded `docker-compose.yml`.
- **Discord Notifications**: Sends notifications to the team with details about the deployment status, including service name, environment, build link, duration, and timestamp.

## Architecture Diagram

```mermaid
flowchart TD
    subgraph G[GitHub Actions]
        GA1[Build Capsule Images]
        GA2[Trivy Image Scan]
        GA3[Snyk Dockerfile Scan]
        GA4[Upload Scan Reports]
    end

    subgraph J[Jenkins Pipeline]
        J1[Confirm Selection]
        J2[Build & Push Capsule Images]
        J3[Trivy Security Scan]
        J4["Ensure VM is Running (Proxmox API)"]
        J5[Fetch Secrets from Vault]
        J6[Pull & Deploy via SSH]
        J7[Send Discord Notification]
    end

    subgraph I[Infrastructure Host: infra.local]
        I1[Vault]
        I2[Local Registry]
        I3[Registry UI]
    end

    subgraph P[Proxmox Hypervisor]
        P1[VM Check]
        P2[Start VM if Stopped]
    end

    subgraph H[Docker Host VM]
        H1[Pull Capsule Image]
        H2["Inject Secrets (.env)"]
        H3[Extract docker-compose.yml]
        H4[Deploy via docker compose up -d]
    end

    GA2 --> GA4
    GA3 --> GA4
    J1 --> J2 --> I2
    J2 --> J3
    J3 --> J4 --> P1 --> P2
    J4 --> J5 --> I1
    J5 --> J6 --> H1 --> H2 --> H3 --> H4
    J6 --> J7
```

## Summary

The CapsuleBay architecture effectively combines cloud-based validation with self-hosted deployment, ensuring a secure and efficient CI/CD pipeline. Each layer plays a critical role in maintaining the integrity and security of the deployment process, allowing for modular and scalable service management.
