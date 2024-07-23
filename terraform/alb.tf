resource "aws_alb" "this" {
  name            = var.name
  internal        = false
  subnets         = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.this.id]
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }
  drop_invalid_header_fields = true
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.this.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    target_group_arn = aws_alb_target_group.this.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.this.id
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

resource "aws_alb_target_group" "this" {
  name                 = "${var.name}-4000"
  port                 = 4000
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 10
  health_check {
    path                = "/healthcheck"
    interval            = 7
    port                = 4000
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
  stickiness {
    type = "lb_cookie"
  }
  lifecycle {
    create_before_destroy = true
  }
}