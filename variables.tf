variable "name" {
  type = "string"
}

variable "app" {
  type = "map"
}

variable "bucket_name" {
  type = "string"
}

variable "certificate_arn" {
  type = "string"
}

variable "private_certificate_arn" {
  type = "string"
  default = ""
}

variable "vpc_id" {
  type = "string"
}

variable "ami_id" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "default_security_group_id" {
  type = "string"
}

variable "root_volume_size" {
  type = "string"
  default = "8"
}

variable "logs_prefix" {
  type = "string"
}

variable "logs_bucket_name" {
  type = "string"
}

variable "region_account_id" {
  type = "string"
}

variable "enable_private" {
  type = "string"
  default = "false"
}
