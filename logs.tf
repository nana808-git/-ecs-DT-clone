data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "logs" {
  bucket = "${var.logs_bucket_name}"
}

data "aws_elb_service_account" "main" {}

data "template_file" "logs" {
  template = "${file("${path.module}/policies/logs.json")}"

  vars {
    prefix            = "${var.logs_prefix}"
    bucket            = "${var.logs_bucket_name}"
    account_id        = "${data.aws_caller_identity.current.account_id}"
    region_account_id = "${data.aws_elb_service_account.main.arn}"
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = "${data.aws_s3_bucket.logs.id}"
  policy = "${data.template_file.logs.rendered}"
}