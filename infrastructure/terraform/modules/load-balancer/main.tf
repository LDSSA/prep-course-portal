#
# This module provides a load balancer that routes traffic to the containers
# running on ECS.
#

// Load Balancer
resource "aws_lb" "_" {
  name               = "${var.app_name}-${var.stage}"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.vpc_subnets
  security_groups    = [aws_security_group._.id]

  tags = {
    Service     = var.app_name
    Environment = var.stage
  }
}

// Load Balancer - Security Group
resource "aws_security_group" "_" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }
  ingress {
    from_port   = 443 # Allowing traffic in from port 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }
  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

// Load Balancer - Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb._.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

// Load Balancer - Listener HTTPS
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb._.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.https_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Could not route this request."
      status_code  = "501"
    }
  }
}
