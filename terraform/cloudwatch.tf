resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "ec2-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    InstanceId = aws_instance.ec2-adnan.id
  }

  alarm_actions = [aws_sns_topic.ec2-updates.arn]

  insufficient_data_actions = []
}
