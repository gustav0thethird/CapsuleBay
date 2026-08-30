# Vault Integration

CapsuleBay integrates with HashiCorp Vault to manage secrets securely during deployments. This integration ensures that sensitive information, such as passwords and API keys, is handled in a secure manner, reducing the risk of exposure during the CI/CD pipeline.

## Overview of Vault Integration

During the deployment process, CapsuleBay retrieves secrets dynamically from Vault. This allows each service capsule to access the necessary credentials without hardcoding them into the application code or configuration files. The secrets are injected into the environment of the deployed service, ensuring that they are available when needed.

## Setting Up Vault

To use Vault with CapsuleBay, you need to enable the KV (Key-Value) secrets engine and store your secrets. Here’s how to set it up:

1. **Enable the KV Secrets Engine:**
   ```bash
   vault secrets enable -path=secret kv-v2
   ```

2. **Store Secrets:**
   For example, to store credentials for the `n8n` service:
   ```bash
   vault kv put secret/n8n/dev N8N_BASIC_AUTH_USER=admin N8N_BASIC_AUTH_PASSWORD=supersecret
   ```

3. **Retrieve Secrets:**
   You can verify that the secrets are stored correctly by running:
   ```bash
   vault kv get secret/n8n/dev
   ```

## Secret Injection During Deployment

When a capsule is deployed, CapsuleBay automatically retrieves the relevant secrets from Vault and injects them into the `.env` file of the service. This process ensures that sensitive information is not exposed in the source code or logs.

## Example of Secret Injection

In the deployment process, the secrets stored in Vault are injected into the environment of the Docker container. For instance, the `n8n` service will have access to the following environment variables:

- `N8N_BASIC_AUTH_USER`
- `N8N_BASIC_AUTH_PASSWORD`

These variables are used by the application to authenticate users securely.

## Security Considerations

Using Vault for secret management provides several security benefits:

- **Decentralized Secrets Management:** Secrets are stored in a centralized location (Vault) and retrieved dynamically, minimizing the risk of exposure.
- **Access Control:** Vault allows fine-grained access control, ensuring that only authorized services can access specific secrets.
- **Audit Logging:** Vault maintains logs of all access to secrets, providing an audit trail for security compliance.

## Conclusion

The integration of HashiCorp Vault with CapsuleBay enhances the security of the deployment process by managing secrets effectively. By following the outlined steps, you can ensure that your applications are deployed securely with the necessary credentials injected at runtime.
