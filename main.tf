## A note on using launch config resources with auto-scaling groups
## https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
## TL;DR assigning this lc_name_prefix var will make life better in the future.


variable "lc_name_prefix" { }
variable "lc_image_id" { }
variable "lc_instance_type" { }
variable "lc_key_name" { }
variable "lc_sec_groups" { type = "list" }
variable "lc_associate_public_ip_address" { default = false }
variable "lc_user_data" { default = "" }
variable "lc_ebs_optimized" { default = false }
variable "lc_instance_profile" { default = "" }

## Build me a Launch Config

resource "aws_launch_configuration" "ec2_launch_config" {
  name_prefix                 = "${var.lc_name_prefix}"
  image_id                    = "${var.lc_image_id}"
  instance_type               = "${var.lc_instance_type}"
  key_name                    = "${var.lc_key_name}"
  security_groups             = "${var.lc_sec_groups}"
  associate_public_ip_address = "${var.lc_associate_public_ip_address}"
  ebs_optimized               = "${var.lc_ebs_optimized}"
  user_data                   = "${var.lc_user_data}"
  iam_instance_profile        = "${var.lc_instance_profile}"
}

output "lc_name" {
  value = "${aws_launch_configuration.ec2_launch_config.name}"
}

## Autoscaling variables

variable "asg_min_size" { default = 1 }
variable "asg_max_size" { }
variable "asg_availability_zones" { type = "list" }
variable "asg_default_cooldown" { default = 300 }
variable "asg_vpc_zone_identifier" { type = "list" }
variable "asg_tag_key" { default = "" }
variable "asg_tag_value" { default = "" }

## And then build me an Autoscaling Group

resource "aws_autoscaling_group" "ec2_autoscaling_group" {
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  availability_zones        = "${var.asg_availability_zones}"
  default_cooldown          = "${var.asg_default_cooldown}"
  launch_configuration      = "${aws_launch_configuration.ec2_launch_config.name}"
  vpc_zone_identifier       = "${var.asg_vpc_zone_identifier}"

  tag {
    key                 = "${var.asg_tag_key}"
    value               = "${var.asg_tag_value}"
    propagate_at_launch = true
  }
}
