variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
  default     = "ec2-updates-topic"
}

variable "notification_email" {
  description = "Email address for notifications"
  type        = string
  default     = "adnan.patel@signiance.com"
}
