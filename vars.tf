variable "github_token" {
  description = "GitHub token"
}

variable "github_webhook_secret" {
  description = "GitHub webhook secret"
}

variable "aws_region" {
    description = "AWS region"
}

variable "aws_account_id" {
    description = "AWS account ID"
}

variable "github_repository" {
  description = "GitHub repository"
  default = ""
}