variable "ecs_cluster_name" {
  description = "The ECS cluster name for CloudWatch alarms"
  type        = string
}

variable "ecs_service_name" {
  description = "The ECS service name for CloudWatch alarms"
  type        = string
  default     = "backend-service"
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "The ARN suffix of the target group for CloudWatch metrics"
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarm notifications"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "ECS CPU utilization threshold percentage"
  type        = number
  default     = 60
}

variable "memory_alarm_threshold" {
  description = "ECS memory utilization threshold percentage"
  type        = number
  default     = 80
}

variable "alb_response_time_threshold" {
  description = "ALB response time threshold in seconds"
  type        = number
  default     = 2
}

variable "alb_request_count_threshold" {
  description = "ALB request count threshold"
  type        = number
  default     = 1000
}

variable "healthy_host_threshold" {
  description = "Minimum number of healthy hosts"
  type        = number
  default     = 1
}
