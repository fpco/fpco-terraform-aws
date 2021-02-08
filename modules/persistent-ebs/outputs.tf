output "volume_ids" {
  value       = aws_ebs_volume.main.*.id
  description = "`id` exported from the `aws_ebs_volume`"
}

output "iam_profile_policy_document" {
  value       = data.aws_iam_policy_document.attach_ebs_policy_doc.json
  description = "`policy` exported from the `aws_iam_role_policy`"
}
