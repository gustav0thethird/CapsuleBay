# Discord Notifications

CapsuleBay sends notifications to Discord at the end of each pipeline run to inform the team about the status of deployments. These notifications are structured as embeds and include relevant details about the service deployment.

## Notification Content

Each Discord notification contains the following information:

- **Service Name**: The name of the service being deployed.
- **Environment**: The target environment for the deployment (e.g., production, staging).
- **Build Link**: A link to the specific build in Jenkins, formatted as `[Build #<build_number>](<build_url>)`.
- **Duration**: The total time taken for the deployment process.
- **Timestamp**: The date and time when the deployment was completed.
- **User Ping**: An optional mention of a user in the Discord channel, formatted as `<@UserID>`.

## Example Notification

An example of a Discord notification sent by CapsuleBay is as follows:

```
CapsuleBay Deployment Successful
Service: portainer
Environment: prod
Build: [#42](https://jenkins.example.local/job/CapsuleBay/42/)
Duration: 2m 34s
Timestamp: 2025-10-26 20:42
```

## Implementation Details

The notifications are sent as part of the Jenkins pipeline, specifically in the step that follows the deployment of the capsule. The webhook URL for the Discord channel must be configured in the Jenkins environment to enable this feature.

### Webhook Configuration

To set up Discord notifications, you need to:

1. Create a webhook in your Discord channel.
2. Copy the webhook URL.
3. Add the webhook URL to your Jenkins environment variables.

### Sending Notifications

The notification is sent using a POST request to the Discord webhook URL with the structured message content. The message format adheres to Discord's embed structure, ensuring that the information is presented clearly and effectively.

By integrating Discord notifications, CapsuleBay enhances team communication and provides real-time updates on deployment statuses, allowing for quicker responses to any issues that may arise during the CI/CD process.
