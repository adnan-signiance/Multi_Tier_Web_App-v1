resource "aws_sns_topic" "ec2-updates" {
  name = "ec2-updates-topic"
}

resource "aws_sns_topic_subscription" "ec2-updates-subscription" {
  topic_arn = aws_sns_topic.ec2-updates.arn
  protocol  = "email"
  endpoint  = "adnan.patel@signiance.com"
}