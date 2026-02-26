# -------------------------------------------------------
# Target Group — ECS EC2 (instance target type)
# ECS registers/deregisters targets automatically via service
# -------------------------------------------------------
resource "aws_lb_target_group" "blue-tg-adnan" {
  name        = "blue-tg-adnan"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name  = "blue-tg-adnan"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }
}

resource "aws_lb_target_group" "green-tg-adnan" {
  name        = "green-tg-adnan"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name  = "green-tg-adnan"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }
}

# -------------------------------------------------------
# Application Load Balancer
# -------------------------------------------------------
resource "aws_lb" "alb-adnan" {
  name               = "alb-adnan"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name  = "alb-adnan"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }
}

# -------------------------------------------------------
# ALB Listener — HTTP on port 80
# -------------------------------------------------------
resource "aws_lb_listener" "alb-listener-adnan" {
  load_balancer_arn = aws_lb.alb-adnan.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue-tg-adnan.arn
  }

  tags = {
    Name  = "alb-listener-adnan"
    User  = "Adnan"
    Usage = "Multi tier Web App"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

