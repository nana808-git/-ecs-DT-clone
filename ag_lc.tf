resource "aws_autoscaling_group" "main" {
  name                      = "${var.app["name"]}-${var.app["env"]}-ag-${var.name}"
  vpc_zone_identifier       = ["${var.private_subnet_ids}"]
  launch_configuration      = "${aws_launch_configuration.main.name}"
  max_size                  = 20
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "EC2"
  force_delete              = true

  tag {
    key = "Name"
    value = "${var.app["name"]}-${var.app["env"]}-ec2-${var.name}"
    propagate_at_launch = true
  }
  tag {
    key = "Application"
    value = "${var.app["name"]}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.app["env"]}"
    propagate_at_launch = true
  }
  tag {
    key = "Purpose"
    value = "${var.name}"
    propagate_at_launch = true
  }
  tag {
    key = "AnsibleRole"
    value = "${var.name}"
    propagate_at_launch = true
  }
  tag {
    key = "BucketName"
    value = "${var.bucket_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.app["name"]}-${var.app["env"]}-lc-${var.name}"
  image_id             = "${var.ami_id}"
  security_groups      = ["${aws_security_group.ec2.id}", "${var.default_security_group_id}"]
  instance_type        = "${var.instance_type}"
  user_data            = "${file("${path.module}/ubuntu.sh")}"
  key_name             = "SystemAdmin"
  iam_instance_profile = "${aws_iam_instance_profile.main.name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device = {
    volume_type = "standard"
    volume_size = "${var.root_volume_size}"
  }
}
