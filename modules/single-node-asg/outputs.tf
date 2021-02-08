output "asg_name" {
  value       = module.server.name
  description = "`name` exported from the Server `aws_autoscaling_group`"
}

output "asg_iam_role_name" {
  value       = module.instance-profile.iam_role_name
  description = "`name` exported from the Service Data `aws_iam_role`"
}

output "data_volume_name_tag" {
  value       = "${local.name_prefix_with_az}-default"
  description = "Name tag value for attached data volume. This is for compatible with old code."
}
