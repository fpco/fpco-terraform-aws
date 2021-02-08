/**
 * ## ASG (Autoscaling Group)
 *
 * The purpose of this module is to provide a Launch Configuration and Autoscaling
 * Group as a pair.
 *
 * The module supports:
 *
 * * spanning N Availability Zones
 * * load balancers may be associated with the ASG
 * * the health checks are not yet parametized, (easy to change)
 * * the Launch Configuration supports an arbitrary list of security groups
 * * `lifecycle` and `create_before_destroy` are used to ensure updates are graceful
 * * public IPs may be enabled/disabled
 * * supports appending `extra_tags`
 * * all important details (instance type, ami, key, user data, iam profile) are
 *   specified as variables in the modules.
 *
 * Note that, Terraform does not run a rolling update when an ASG/LC pair have
 * changed. After the ASG/LC have been updated, the EC2 instances running before
 * the update will still be running. As a result, you will need to terminate each
 * of those instances to perform a rolling update.
 *
 */
# Auto-Scaling Group
resource "aws_autoscaling_group" "cluster" {
  force_delete              = true
  health_check_grace_period = 300
  health_check_type         = var.health_check_type
  launch_configuration      = aws_launch_configuration.cluster.name
  load_balancers            = var.elb_names
  max_size                  = var.max_nodes
  min_size                  = var.min_nodes
  name_prefix               = local.name_prefix
  placement_group           = var.placement_group
  termination_policies      = var.termination_policies
  protect_from_scale_in     = var.protect_from_scale_in
  suspended_processes       = var.suspended_processes

  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier = var.subnet_ids

  dynamic "initial_lifecycle_hook" {
    for_each = var.enable_launching_hook ? [1] : []
    content {
      name                    = "${var.name_prefix}-lifecycle-launching"
      default_result          = "CONTINUE"
      heartbeat_timeout       = 60
      lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_target_arn = var.lifecycle_sns_topic_arn
      role_arn                = var.aws_role_arn
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.enable_terminating_hook ? [1] : []
    content {
      name                    = "${var.name_prefix}-lifecycle-terminating"
      default_result          = "CONTINUE"
      heartbeat_timeout       = 60
      lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_target_arn = var.lifecycle_sns_topic_arn
      role_arn                = var.aws_role_arn
    }
  }

  tags = concat(
    [
      {
        "key"                 = "Name"
        "value"               = local.name_prefix
        "propagate_at_launch" = true
      },
    ],
    var.extra_tags,
  )
}

# Launch Config for the ASG
resource "aws_launch_configuration" "cluster" {
  # omit name so it's generated as a unique value
  associate_public_ip_address = var.public_ip
  iam_instance_profile        = var.iam_profile
  image_id                    = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = var.security_group_ids
  user_data                   = var.user_data

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    encrypted   = var.root_encrypted
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_block_devices
    content {
      device_name = ebs_block_device.value.device_name
      volume_type = ebs_block_device.value.volume_type
      volume_size = ebs_block_device.value.volume_size
      encrypted   = ebs_block_device.value.encrypted
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Attach ASG to the load balancer target group
resource "aws_autoscaling_attachment" "main" {
  count                  = length(var.alb_target_group_arns)
  autoscaling_group_name = aws_autoscaling_group.cluster.name
  alb_target_group_arn   = var.alb_target_group_arns[count.index]
}
