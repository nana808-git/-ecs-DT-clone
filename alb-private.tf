resource "aws_lb" "private" {
  count              = "${var.enable_private == "true" ? 1 : 0}"
  name               = "${var.app["name"]}-${var.app["env"]}-alb-${var.name}-private"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_private.id}", "${var.default_security_group_id}"]
  subnets            = ["${var.private_subnet_ids}"]
  idle_timeout       = 400

  access_logs {
    bucket  = "${var.logs_bucket_name}"
    prefix  = "${var.logs_prefix}"
    enabled = true
  }

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-alb-${var.name}-private"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
  }

  depends_on = ["aws_s3_bucket_policy.logs"]
}

resource "aws_lb_listener" "https-private" {
  count              = "${var.enable_private == "true" ? 1 : 0}"

  load_balancer_arn = "${aws_lb.private.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.private_certificate_arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "http-private" {
  count              = "${var.enable_private == "true" ? 1 : 0}"

  load_balancer_arn = "${aws_lb.private.arn}"
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
