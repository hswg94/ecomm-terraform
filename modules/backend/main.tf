////////////////////////////////////////////////////////////////////
// Security Groups

resource "aws_security_group" "ec2" {
  name        = "ec2-sg"
  description = "Allow HTTP and ICMP traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Restrict to ALB SG
  }

  # Inbound rules
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP traffic from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (allow all by default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTPS and ICMP traffic to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

////////////////////////////////////////////////////////////////////
// IAM

# Create IAM Role to allow EC2 to access Secrets Manager, CodeDeploy and CloudWatch Logs.
resource "aws_iam_role" "ec2" {
  name = "EC2AccessSMandCDRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  for_each = {
    SecretsManagerReadWrite       = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    AmazonEC2RoleforAWSCodeDeploy = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
    CloudWatchAgentServerPolicy   = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    CloudWatchLogsFullAccess      = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    AmazonSSMManagedInstanceCore  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  role       = aws_iam_role.ec2.id
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2" {
  name = "EC2AccessSMandCDInstanceProfile"
  role = aws_iam_role.ec2.name
}

////////////////////////////////////////////////////////////////////
// EC2 Launch Template

# userdata.sh fetches the CloudWatch Agent config from this parameter by name
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name  = "cloudwatch-agent-config"
  type  = "String"
  value = file("${path.module}/cloudwatch-agent-config.json")
}

resource "aws_launch_template" "api" {
  name          = "ecomm-api-lt"
  description   = "launch template for ecomm-api deployment to ec2, use with auto scaling groups"
  instance_type = "t2.micro"
  image_id      = "ami-039454f12c36e7620" //Amazon Linux 2023

  # IAM role for EC2 instance
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.id
  }

  # Security Group reference
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Optional: User data script
  user_data = filebase64("${path.module}/userdata.sh")

  depends_on = [aws_ssm_parameter.cloudwatch_agent_config]
}

////////////////////////////////////////////////////////////////////
// Load Balancer and Auto Scaling

resource "aws_lb" "api" {
  name               = "ecomm-api-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  /// Deploying across 2 subnets in different AZs, IPv4 address costs will incur per AZ.
  subnets = var.subnet_ids
}

# Listener for load balance to forward traffic to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

// Target Group that consists of an auto-scaling group
resource "aws_lb_target_group" "api" {
  name     = "ecomm-api-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health" #healthcheck endpoint in API
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "api" {
  name = "ecomm-api-asg"
  // single-az
  desired_capacity = 1 //The instances at launch
  max_size         = 4
  min_size         = 1
  // multi-az
  # desired_capacity = 2 // The instances at launch
  # max_size         = 4
  # min_size         = 2
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.api.arn]
  launch_template {
    id      = aws_launch_template.api.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "ecomm-api-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.api.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
  enabled = true
}

////////////////////////////////////////////////////////////////////
// DNS Records

//Create Records for API
resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = var.api_domain
  type    = "A"

  alias {
    name                   = aws_lb.api.dns_name
    zone_id                = aws_lb.api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "api_www" {
  zone_id = var.zone_id
  name    = "www.${var.api_domain}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_route53_record.api.name]
}
