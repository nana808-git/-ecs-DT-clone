output "alb_security_group_id" { 
  value = "${aws_security_group.alb.id}" 
}

output "alb_private_security_group_id" { 
  value = "${aws_security_group.alb_private.id}" 
}

output "https_listener_arn" { 
  value = "${aws_lb_listener.https.arn}" 
}

output "ec2_security_group_id" { 
  value = "${aws_security_group.ec2.id}" 
}

output "iam_role_name" { 
  value = "${aws_iam_role.main.name}"
}