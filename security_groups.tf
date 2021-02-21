resource "aws_security_group" "alb" {
  name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-alb"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-alb"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
    Component   = "alb"
  }
}

resource "aws_security_group" "alb_private" {
  name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-alb-private"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-alb-private"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
    Component   = "alb"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-ec2" 
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.alb.id}", "${aws_security_group.alb_private.id}"]
  }

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-sg-${var.name}-ec2"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
    Component   = "ec2"
  }
}
