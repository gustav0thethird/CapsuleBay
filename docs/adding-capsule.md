# Adding a New Capsule

To create and deploy a new service capsule in CapsuleBay, follow the steps outlined below.

## Step 1: Create the Capsule Directory

1. Navigate to the `capsules` directory in your local repository.
2. Create a new directory for your capsule. The name should reflect the service you are creating (e.g., `my-new-service`).

## Step 2: Create the Dockerfile

1. Inside your new capsule directory, create a `Dockerfile`.
2. Define the necessary instructions to build your service image. Ensure that the base image and any dependencies are correctly specified.

## Step 3: Create the Docker Compose File

1. In the same directory, create a `docker-compose.yml` file.
2. Define the services, networks, and volumes required for your capsule. Ensure that the service name matches the directory name.

## Step 4: Update CI/CD Configuration

1. Modify the `.github/workflows/CI.yml` file to include your new capsule.
   - Add a new job for building and scanning your capsule image.
   - Ensure that the image tag reflects your capsule name.

2. Update the `.github/workflows/snyk.yml` file to include a scan for your new Dockerfile.

## Step 5: Create a Catalog Entry

1. Create or update the `catalog-info.yaml` file in the root of your capsule directory.
2. Ensure that the metadata includes the name, description, and any relevant annotations.

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-new-service
  description: A brief description of your service.
spec:
  type: service
  lifecycle: experimental
  owner: your-username
```

## Step 6: Build and Test Your Capsule

1. Use Docker Compose to build and run your capsule locally:

   ```bash
   docker-compose up --build
   ```

2. Verify that the service is running as expected.

## Step 7: Deploy Your Capsule

1. Push your changes to the repository.
2. The CI/CD pipeline will automatically trigger, building and scanning your capsule image.

## Step 8: Monitor and Maintain

1. Monitor the CI/CD pipeline for any issues during the build and scan processes.
2. Regularly update your capsule as needed, following the same steps for modifications.

By following these steps, you can successfully create and deploy a new service capsule in CapsuleBay.
