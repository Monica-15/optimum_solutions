variable "agency_count" {
  description = "Number of agencies"
  type        = number
}

variable "agencies" {
  description = "List of agencies with their names and bucket names"
  type = list(object({
    name        = string
    bucket_name = string
  }))
}

variable "alert_email" {
  description = "Email for SNS alerts"
  type        = string
}

variable "slack_channel_id" {
  description = "Slack channel ID for AWS Chatbot"
  type        = string
}

variable "slack_workspace_id" {
  description = "Slack workspace ID for AWS Chatbot"
  type        = string
}
