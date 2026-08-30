# Discord Notifications

At the end of each pipeline run, CapsuleBay sends a Discord notification to inform the team about the status of the deployment. The notification is structured as an embedded message and includes the following details:

- **Service Name**: The name of the service that was deployed.
- **Environment**: The environment in which the service was deployed (e.g., development, staging, production).
- **Build Link**: A hyperlink to the specific build in Jenkins, formatted as `[Build #<build_number>](<build_url>)`.
- **Duration**: The total time taken for the build and deployment process.
- **Timestamp**: The date and time when the deployment occurred.
- **User Ping**: An optional mention of a user in the Discord channel, formatted as `<@UserID>`.

### Example Notification

An example of a typical Discord notification sent by CapsuleBay is as follows:

```
CapsuleBay Deployment Successful
Service: portainer
Environment: prod
Build: [#42](https://jenkins.example.local/job/CapsuleBay/42/)
Duration: 2m 34s
Timestamp: 2025-10-26 20:42
```

### Notification Trigger

The Discord notification is triggered at the end of the Jenkins pipeline, specifically after the deployment step is completed. This ensures that the team is promptly informed of the deployment status, allowing for quick responses to any issues that may arise.

### Configuration

The Discord notifications are configured to use a webhook, which must be set up in the Discord server where notifications will be sent. The webhook URL is typically stored in the environment variables or configuration files used by the Jenkins pipeline.

### Summary

The Discord notifications feature in CapsuleBay enhances team communication by providing real-time updates on deployment activities, ensuring that all team members are aware of the current state of the services they are responsible for.
