resource "aws_autoscaling_group" "cluster" {
  name                 = "${var.name_prefix}-${aws_launch_configuration.cluster.name}"
  launch_configuration = aws_launch_configuration.cluster.id
  vpc_zone_identifier  = module.vpc.public_subnet_ids

  min_size         = 1
  desired_capacity = 2
  max_size         = 4

  lifecycle {
    create_before_destroy = true
  }

  initial_lifecycle_hook {
    name                    = "${var.name_prefix}-lifecycle"
    default_result          = "CONTINUE"
    heartbeat_timeout       = 60
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    notification_target_arn = aws_sns_topic.main.arn
    role_arn                = aws_iam_role.lifecycle_hook.arn
  }
}

# Launch Config for the ASG
resource "aws_launch_configuration" "cluster" {
  name_prefix          = var.name_prefix
  image_id             = data.aws_ami.linux2.id
  instance_type        = "t2.nano"
  key_name             = aws_key_pair.main.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  security_groups      = [aws_security_group.main.id]

  user_data = data.template_file.main.rendered

  lifecycle {
    create_before_destroy = true
  }
}
