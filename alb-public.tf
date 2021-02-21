resource "aws_lb" "main" {
  name               = "${var.app["name"]}-${var.app["env"]}-alb-${var.name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}", "${var.default_security_group_id}"]
  subnets            = ["${var.public_subnet_ids}"]
  idle_timeout       = 400

  access_logs {
    bucket  = "${var.logs_bucket_name}"
    prefix  = "${var.logs_prefix}"
    enabled = true
  }

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-alb-${var.name}"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
  }

  depends_on = ["aws_s3_bucket_policy.logs"]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.main.arn}"
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
