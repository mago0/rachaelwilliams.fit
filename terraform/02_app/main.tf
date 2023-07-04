provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "rachaelwilliams-terraform"
    key    = "01_base/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

locals {
  app_name = "webapp-${terraform.workspace}"
  environment_settings = {
    stag = {
      desired_count = 1
      image_tag     = "latest"
      domain_name   = "stag.rachaelwilliams.fit"
      secret_arn_stripe_secret_key = "arn:aws:secretsmanager:us-east-1:595378669852:secret:stag/stripe_secret_key-wVNCOD"
    }
    prod = {
      desired_count = 1
      image_tag     = "prod"
      domain_name   = "rachaelwilliams.fit"
      secrets_arn   = "todo"
    }
  }
  principal_arn = "arn:aws:iam::595378669852:root" 
  account_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  route53_zone_id = "Z0902220170DUSA4HJFLM"
  webapp_certificate_arn = "arn:aws:acm:us-east-1:595378669852:certificate/53848242-be16-4615-bd04-ab273f909789"

  settings = lookup(local.environment_settings, terraform.workspace)
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = terraform.workspace
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${local.app_name}-container-logs"
  retention_in_days = 7
}

# Create an ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = local.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = local.app_name
      image     = "${data.terraform_remote_state.base.outputs.ecr_repository_url}:${local.settings.image_tag}"
      essential = true

      secrets = [
        {
          name      = "STRIPE_SECRET_KEY"
          valueFrom = local.settings.secret_arn_stripe_secret_key
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = terraform.workspace
        }
      ]

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = local.app_name
        }
      }
    }
  ])
}

# Create an ECS Service
resource "aws_ecs_service" "this" {
  name            = local.app_name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = local.settings.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.base.outputs.public_subnet_ids
    security_groups = [data.terraform_remote_state.base.outputs.ecs_security_group_id]
  }
  cluster = aws_ecs_cluster.this.id

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.app_name
    container_port   = 3000
  }
}

# Add necessary IAM roles
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_policy" "custom_execution_role_policy" {
  name = "custom_ecs_execution_role_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:*"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.this.arn
      },
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = data.terraform_remote_state.base.outputs.ses_identity_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_execution_policy_attachment" {
  policy_arn = aws_iam_policy.custom_execution_role_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}

# Configure Route53 entry
resource "aws_route53_record" "this" {
  zone_id = local.route53_zone_id
  name    = local.settings.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

# Create a Load Balancer
resource "aws_lb" "this" {
  name               = local.app_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.base.outputs.alb_security_group_id]
  subnets            = data.terraform_remote_state.base.outputs.public_subnet_ids
}

# Create a Load Balancer target group
resource "aws_lb_target_group" "this" {
  name     = local.app_name
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.base.outputs.vpc_id
  target_type = "ip"
  health_check {
    path = "/healthz"
    port = "traffic-port"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
  }
}

# Add the Load Balancer HTTP listener (port 80)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port         = "443"
      protocol     = "HTTPS"
      status_code  = "HTTP_301"
    }
  }
}

# Add the Load Balancer HTTPS listener (port 443)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.webapp_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
