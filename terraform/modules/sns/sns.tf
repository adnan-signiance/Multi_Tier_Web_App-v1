resource "aws_sns_topic" "ec2-updates" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "ec2-updates-subscription" {
  topic_arn = aws_sns_topic.ec2-updates.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
