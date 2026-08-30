# System Architecture

CapsuleBay is divided into two CI/CD layers:

### 1. GitHub Actions – Cloud Validation Layer
This layer runs automatically on every push or pull request and is responsible for:
- Building capsule images for validation.
- Running Trivy image scans to identify vulnerabilities with HIGH and CRITICAL severity.
- Executing Snyk Dockerfile scans to detect dependency-level issues.
- Uploading scan reports as artifacts for review.

This process ensures that all commits are secure, compliant, and buildable before they reach the Jenkins deployment layer.

### 2. Jenkins – Self-Hosted Deployment Layer
This layer manages controlled, Vault-secured deployments within your local area network (LAN). Its responsibilities include:
- Building, tagging, and pushing capsule images to a local registry.
- Dynamically retrieving secrets from Vault.
- Ensuring the target virtual machine (VM) is powered on using the Proxmox API.
- Performing a second security scan on built images using Trivy.
- Deploying capsules remotely with their embedded `docker-compose.yml`.
- Sending Discord notifications that include service details, environment, build link, duration, and timestamp.

---

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

---

## Summary

CapsuleBay's architecture leverages both GitHub Actions for cloud-based validation and Jenkins for self-hosted deployments, ensuring a robust and secure CI/CD pipeline. Each layer plays a critical role in maintaining the integrity and security of the deployment process, from initial code validation to final deployment.
