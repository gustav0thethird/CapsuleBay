# Security Stack

CapsuleBay integrates layered security checks to ensure the integrity and safety of deployments. The following tools and processes are employed throughout the CI/CD pipeline:

| Layer | Tool | Purpose |
|--------|------|----------|
| **GitHub Actions (pre-merge)** | **Trivy** | Scans built images for vulnerabilities, focusing on HIGH and CRITICAL severity issues. |
| | **Snyk** | Scans Dockerfiles for dependency vulnerabilities (CVEs). |
| **Jenkins (pre-deploy)** | **Trivy CLI** | Rescans the final image before deployment to catch any new vulnerabilities. |
| **Vault** | **HashiCorp Vault** | Securely manages and delivers secrets required for deployments. |
| **Discord** | **Webhook alerts** | Sends notifications regarding the success or failure of builds, including relevant links and timestamps. |

## Detailed Breakdown of Security Checks

### GitHub Actions – Cloud Validation Layer
- **Trivy**: Automatically runs on every push or pull request to validate capsule images. It checks for vulnerabilities and generates reports that are uploaded as artifacts for review.
- **Snyk**: Scans Dockerfiles for known vulnerabilities, ensuring that dependencies are secure before they are merged into the main branch.

### Jenkins – Self-Hosted Deployment Layer
- **Trivy CLI**: Conducts a final security scan of the capsule images before they are deployed. This step is crucial to ensure that no vulnerabilities were introduced after the initial scans.
- **Vault**: Retrieves secrets dynamically for each deployment, ensuring that sensitive information is not hard-coded into the images or configurations.

### Notification System
- **Discord Notifications**: At the end of each pipeline run, CapsuleBay sends a detailed message to a designated Discord channel. This message includes:
  - Service name
  - Environment (e.g., dev, staging, prod)
  - Build link (e.g., a link to the Jenkins build)
  - Duration of the build
  - Timestamp of the deployment
  - User ping for relevant team members

This multi-layered approach to security ensures that CapsuleBay maintains a high standard of safety and compliance throughout its deployment processes. Each layer of security builds upon the previous one, creating a robust framework for managing and deploying applications securely.
