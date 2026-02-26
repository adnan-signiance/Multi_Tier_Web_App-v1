# -------------------------------------------------------
# Data source: Latest ECS-optimized Amazon Linux 2 AMI
# -------------------------------------------------------
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# -------------------------------------------------------
# ECS Cluster
# -------------------------------------------------------
resource "aws_ecs_cluster" "ecs-cluster-adnan" {
  name = "ecs-cluster-adnan"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name  = "ecs-cluster-adnan"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }
}

# -------------------------------------------------------
# Launch Template for ECS EC2 instances
# -------------------------------------------------------
resource "aws_launch_template" "ecs_adnan" {
  name_prefix   = "ecs-adnan-"
  image_id      = data.aws_ami.ecs.id
  instance_type = "t3.small"

  vpc_security_group_ids = [var.ecs_security_group_id]

  iam_instance_profile {
    arn = var.ecs_instance_profile_arn
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-adnan.name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "ecs-adnan-instance"
      User  = "Adnan"
      Usage = "Multi tier Web App"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name  = "ecs-adnan-volume"
      User  = "Adnan"
      Usage = "Multi tier Web App"
    }
  }
}

resource "aws_autoscaling_group" "ecs" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 1

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.ecs_adnan.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "User"
    value               = "Adnan"
    propagate_at_launch = true
  }

  tag {
    key                 = "Usage"
    value               = "Multi tier Web App"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "ecs-adnan-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "cp" {
  name = "ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "attach" {
  cluster_name = aws_ecs_cluster.ecs-cluster-adnan.name

  capacity_providers = [aws_ecs_capacity_provider.cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
  }
}

# -------------------------------------------------------
# ECS Task Definition — FIXED
# -------------------------------------------------------
resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]

  # ✅ FIX 1: REQUIRED task-level CPU & memory
  cpu    = "512"
  memory = "1024"

  # ✅ FIX 2: Recommended execution role
  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "server"
      image = "${aws_ecr_repository.backend.repository_url}:latest"

      cpu    = 512
      memory = 512

      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }]

      environment = [
        { name = "DB_HOST", value = var.db_host },
        { name = "DB_NAME", value = var.db_name },
        { name = "PORT", value = "5000" }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app-task/server"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "server"
        }
      }

      essential = true
    },
    {
      name  = "client"
      image = "${aws_ecr_repository.frontend.repository_url}:latest"

      memory = 512

      portMappings = [{
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }]

      dependsOn = [{
        containerName = "server"
        condition     = "START"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app-task/client"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "client"
        }
      }

      essential = true
    }
  ])
}

# -------------------------------------------------------
# ECS Service
# -------------------------------------------------------
resource "aws_ecs_service" "app" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.ecs-cluster-adnan.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_security_group_id]
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "client"
    container_port   = 80
  }

  tags = {
    Name  = "app-service"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }

  depends_on = [aws_ecs_cluster_capacity_providers.attach]

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      desired_count,
    ]
  }
}


# -------------------------------------------------------
# CloudWatch Log Groups
# -------------------------------------------------------
resource "aws_cloudwatch_log_group" "server" {
  name              = "/ecs/app-task/server"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "client" {
  name              = "/ecs/app-task/client"
  retention_in_days = 7
}
