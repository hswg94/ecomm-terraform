resource "aws_lb" "ecomm-api-alb" {
  name               = "ecomm-api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]
}

# Listener for load balance to forward traffic to target group
resource "aws_lb_listener" "ecomm-api-listener" {
  load_balancer_arn = aws_lb.ecomm-api-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.ap-southeast-1-cert.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecomm-api-tg.arn
  }
}


// Target Group that consists of an auto-scaling group
resource "aws_lb_target_group" "ecomm-api-tg" {
  name     = "ecomm-api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.MyFypVpc.id

  health_check {
    path                = "/health" #healthcheck endpoint in API
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "ecomm-api-asg" {
  name             = "ecomm-api-asg"
  desired_capacity = 2 //The instances at launch
  max_size         = 4
  min_size         = 2
  vpc_zone_identifier = [
    aws_subnet.public-subnet-1.id,
    aws_subnet.public-subnet-2.id
  ]
  target_group_arns = [aws_lb_target_group.ecomm-api-tg.arn]
  launch_template {
    id      = aws_launch_template.ecomm-api-lt.id
    version = "$Latest"
  }
}