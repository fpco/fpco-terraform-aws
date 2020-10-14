output "asg_id" {
  value       = aws_autoscaling_group.cluster.id
  description = "The autoscaling group id."
}
