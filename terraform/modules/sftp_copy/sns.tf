resource "aws_sns_topic" "alert_topic" {
  name = "MissingFileAlerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_chatbot_slack_channel_configuration" "slack_alerts" {
  configuration_name = "SlackAlerts"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.alert_topic.arn]
}
