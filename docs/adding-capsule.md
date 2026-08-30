# Adding a New Capsule

To create and deploy a new service capsule in the CapsuleBay repository, follow the steps outlined below.

## Step 1: Create the Capsule Directory

1. Navigate to the root of the CapsuleBay repository.
2. Create a new directory for your capsule under the appropriate service folder (e.g., `whoami`, `n8n`, etc.).

## Step 2: Create the Dockerfile

1. Inside your capsule directory, create a `Dockerfile`.
2. Define the necessary instructions for building your service. Ensure that you follow the structure used in existing capsules.

## Step 3: Create the Docker Compose File

1. In your capsule directory, create a `docker-compose.yml` file.
2. Define the services, networks, and volumes required for your capsule. Refer to existing `docker-compose.yml` files for structure and syntax.

## Step 4: Update CI Workflows

1. Open the `.github/workflows/CI.yml` file.
2. Add a new job for your capsule under the `build` section. Ensure it follows the format of existing jobs, specifying the context and tags appropriately.

## Step 5: Security Scanning

1. Open the `.github/workflows/snyk.yml` file.
2. Add a new step to build and scan your capsule's Dockerfile. Use the same approach as existing entries, ensuring to set the image name correctly.

## Step 6: Testing Your Capsule

1. Run the Docker Compose command to build and start your capsule locally:
   ```bash
   docker-compose up --build
   ```
2. Verify that your service is running as expected.

## Step 7: Commit and Push Changes

1. Add your new capsule directory and files to the Git index:
   ```bash
   git add <your-capsule-directory>
   ```
2. Commit your changes:
   ```bash
   git commit -m "Add new capsule: <capsule-name>"
   ```
3. Push your changes to the repository:
   ```bash
   git push origin <branch-name>
   ```

## Step 8: Monitor CI/CD Pipeline

1. After pushing, monitor the GitHub Actions tab for the status of your CI/CD pipeline.
2. Ensure that the build and security scans complete successfully.

## Conclusion

Following these steps will allow you to create and deploy a new service capsule in the CapsuleBay repository. Make sure to adhere to existing conventions and practices for consistency.
