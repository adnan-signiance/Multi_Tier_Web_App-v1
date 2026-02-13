resource "aws_lb_target_group" "tg-adnan" {
  name     = "tg-adnan"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-adnan.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb" "alb-adnan" {
  name               = "alb-adnan"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg-adnan.id]
  subnets            = [aws_subnet.publicsubnet1-adnan.id, aws_subnet.publicsubnet2-adnan.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "alb-listener-adnan" {
  load_balancer_arn = aws_lb.alb-adnan.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-adnan.arn
  }
}

resource "aws_lb_target_group_attachment" "tg-attachment-adnan" {
  target_group_arn = aws_lb_target_group.tg-adnan.arn
  target_id        = aws_instance.ec2-adnan.id
  port             = 80
}

