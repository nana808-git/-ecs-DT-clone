resource "aws_iam_instance_profile" "main" {
  name = "${var.app["name"]}-${var.app["env"]}-profile-${var.name}"
  role = "${aws_iam_role.main.name}"
}

resource "aws_iam_role" "main" {
  name        = "${var.app["name"]}-${var.app["env"]}-role-${var.name}"

  assume_role_policy = "${file("${path.module}/policies/assume_role.json")}"

  tags = {
    Name        = "${var.app["name"]}-${var.app["env"]}-role-${var.name}"
    Application = "${var.app["name"]}"
    Environment = "${var.app["env"]}"
    Purpose     = "${var.name}"
  }
}

resource "aws_iam_policy" "tags" {
  name        = "${var.app["name"]}-${var.app["env"]}-policy-${var.name}-tags"
  description = "ec2 access to delete and describe tags"
  policy      = "${file("${path.module}/policies/tags.json")}"
}

resource "aws_iam_policy_attachment" "tags" {
  name       = "${var.app["name"]}-${var.app["env"]}-attach-${var.name}-tags"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.tags.arn}"
}

resource "aws_iam_policy" "ecr" {
  name        = "${var.app["name"]}-${var.app["env"]}-policy-${var.name}-ecr"
  description = "ECR pull containers"
  policy      = "${file("${path.module}/policies/ecr.json")}"
}

resource "aws_iam_policy_attachment" "ecr" {
  name       = "${var.app["name"]}-${var.app["env"]}-attach-${var.name}-ecr"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.ecr.arn}"
}

resource "aws_iam_policy" "ecs" {
  name        = "${var.app["name"]}-${var.app["env"]}-policy-${var.name}-ecs"
  description = "ECR pull containers"
  policy      = "${file("${path.module}/policies/ecs.json")}"
}

resource "aws_iam_policy_attachment" "ecs" {
  name       = "${var.app["name"]}-${var.app["env"]}-attach-${var.name}-ecs"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.ecs.arn}"
}

data "template_file" "ansible" {
  template = "${file("${path.module}/policies/ansible.json")}"

  vars {
    name        = "${var.app["name"]}"
    env         = "${var.app["env"]}"
    role        = "${var.name}"
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_iam_policy" "ansible" {
  name        = "${var.app["name"]}-${var.app["env"]}-policy-${var.name}-ansible"
  description = "ec2 s3 access to ansible manifests"
  policy      = "${data.template_file.ansible.rendered}"
}

resource "aws_iam_policy_attachment" "ansible" {
  name       = "${var.app["name"]}-${var.app["env"]}-attach-${var.name}-ansible"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.ansible.arn}"
}

data "template_file" "secretmanager" {
  template = "${file("${path.module}/policies/secretmanager.json")}"

  vars {
    name        = "${var.app["name"]}"
    env         = "${var.app["env"]}"
    role        = "${var.name}"
  }
}

resource "aws_iam_policy" "secretmanager" {
  name        = "${var.app["name"]}-${var.app["env"]}-policy-${var.name}-secretmanager"
  description = "ec2 access to secretmanager passwords"
  policy      = "${data.template_file.secretmanager.rendered}"
}

resource "aws_iam_policy_attachment" "secretmanager" {
  name       = "${var.app["name"]}-${var.app["env"]}-attach-${var.name}-secretmanager"
  roles      = ["${aws_iam_role.main.name}"]
  policy_arn = "${aws_iam_policy.secretmanager.arn}"
}
