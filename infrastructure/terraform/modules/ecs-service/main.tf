#
# This module defines the ECS service, where the application container
# will run
#

// Local variables
locals {
  container_name = "${var.app_name}_${var.stage}_container"
}

// ECS Server Task Role
// Required so the container in the task can access other AWS services
resource "aws_iam_role" "ecs_server_task_role" {
  name               = "${var.app_name}-${var.stage}-ecs_server_task_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// ECS - Execution role
// Required so that fargate can pull containers from ECR.
resource "aws_iam_role" "ecs_server_execution_role" {
  name = "${var.app_name}-${var.stage}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// ECS - Execution role policy
resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "${var.app_name}-${var.stage}-ecs-execution-policy"
  description = "A policy to manage the access to ECR from ECS."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

// ...attaching execution policy
resource "aws_iam_policy_attachment" "attach_execution_policy" {
  name       = "${var.app_name}-${var.stage}-ecs-execution-policy-attachment"
  roles      = [aws_iam_role.ecs_server_execution_role.name]
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

// ECS security group
resource "aws_security_group" "service_security_group" {
  vpc_id = var.vpc_id

  # allow all
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.lb_security_group_id]
  }

  # allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// Cloudwatch - Log Group
resource "aws_cloudwatch_log_group" "_" {
  name = "${var.app_name}-${var.stage}_log_group"

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// ECS - Task Definition
// All future revisions should be managed by an external process.
resource "aws_ecs_task_definition" "_" {
  family             = "${var.app_name}-${var.stage}_task"
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs_server_task_role.arn
  execution_role_arn = aws_iam_role.ecs_server_execution_role.arn

  container_definitions = templatefile(
    "modules/ecs-service/data/container_definition.json",
    {
      container_name    = local.container_name
      image             = "${var.repository_url}:${var.docker_tag}"
      stage             = var.stage
      region            = var.region
      django_secret_key = var.django_secret_key
      db_host           = var.db_host
      db_port           = var.db_port
      db_name           = var.db_name
      db_username       = var.db_username
      db_password       = var.db_password
      container_port    = var.container_port
      awslogs_group     = aws_cloudwatch_log_group._.name
    }
  )

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// ECS - Service
resource "aws_ecs_service" "_" {
  name                              = "${var.app_name}-${var.stage}_service"
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition._.arn
  desired_count                     = var.service_desired_count
  health_check_grace_period_seconds = var.service_health_check_grace_period_seconds
  launch_type                       = "FARGATE"
  enable_execute_command            = true

  load_balancer {
    target_group_arn = aws_lb_target_group._.arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.vpc_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.service_security_group.id]
  }

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

// Load Balancer - Target Group
resource "aws_lb_target_group" "_" {
  name                 = "${var.app_name}-${var.stage}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = var.server_target_group_deregistration_delay

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }

  health_check {
    port    = var.container_port
    matcher = "200"
    path    = "/health"
  }

  depends_on = [var.lb_dns]
}

// Load Balancer - Listener Rule (HTTP)
// Forwards the inbound traffic to port 443
resource "aws_lb_listener_rule" "route_to_server_http" {
  listener_arn = var.lb_http_listener_arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  depends_on = [var.lb_http_listener_arn]
}

// Load Balancer - Listener Rule (HTTPS)
resource "aws_lb_listener_rule" "route_to_server_https" {
  listener_arn = var.lb_https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group._.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  depends_on = [var.lb_https_listener_arn]
}

// Security group
resource "aws_security_group" "allow_requests_to_server" {
  name        = "${var.app_name}-${var.stage}-allow_requests_to_server"
  description = "Allow requests on port 8000"
  vpc_id      = var.vpc_id

  ingress {
    description = "Requests from Load Balancer"
    from_port   = 0
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}
