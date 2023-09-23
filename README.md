# GitHub Pull Request Logger

This infrastructure, set up by Terraform, allows you to log file changes (added, changed, deleted) from GitHub merged pull requests using AWS services. When a pull request is merged, GitHub sends a payload to an API Gateway, which in turn triggers a Lambda function. The Lambda function processes the payload, identifies file changes, and logs them in AWS CloudWatch Logs.

## Overview

1. **GitHub Pull Request Merging**: When a pull request is successfully merged on GitHub, it generates a payload containing information about the merged changes.

2. **AWS API Gateway**: An API Gateway receives incoming payloads from GitHub and acts as a trigger for the Lambda function.

3. **AWS Lambda Function**: The Lambda function is responsible for processing the payload and extracting information about added, changed, and deleted files.

4. **AWS CloudWatch Logs**: The Lambda function logs the file changes (added, changed, deleted) in CloudWatch Logs for future reference and monitoring.

## Setup Instructions

Follow these steps to set up the infrastructure using Terraform:

1. **Clone This Repository**: Clone this repository to your local development environment.

2. **Configure GitHub Webhook**: Configure a GitHub webhook to send payload data to the API Gateway URL provided in the next step.

3. **Deploy Terraform Configuration**: Use Terraform to deploy the infrastructure. Ensure that you have Terraform installed and configured with your AWS credentials.

   ```shell
   terraform init
   terraform apply
    ```
4. **Test Infrastructure**: Create a pull request and merge it to test the infrastructure. Check the CloudWatch Logs for the Lambda function to see the logged file changes.