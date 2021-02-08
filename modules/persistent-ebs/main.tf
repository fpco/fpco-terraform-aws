/**
 * ## Persistent Data on EBS
 *
 * This module provides an EBS volume and associated IAM profile/role to be
 * used with an EC2 instance or auto-scaling group. This module is best when
 * used in conjunction with a single-node auto-scaling group, and with the
 * init-snippet that attaches the named EBS volume on boot.
 *
 */

resource "aws_ebs_volume" "main" {
  count = length(local.volumes_default)

  availability_zone = var.az
  size              = local.volumes_default[count.index].size
  type              = local.volumes_default[count.index].type
  encrypted         = local.volumes_default[count.index].encrypted
  kms_key_id        = local.volumes_default[count.index].kms_key_id
  snapshot_id       = local.volumes_default[count.index].snapshot_id

  # merge Name w/ extra_tags
  tags = merge(
    {
      "Name" = "${var.name_prefix}-${var.az}-${local.volumes_default[count.index].name}"
    },
    var.extra_tags,
  )
}

# IAM policy that allows attaching this EBS volume to an EC2 instance
resource "aws_iam_policy" "attach_ebs" {
  name   = "${var.name_prefix}-attach-ebs"
  policy = data.aws_iam_policy_document.attach_ebs_policy_doc.json
}

# Attach that IAM policy to the IAM role referenced by the module user
resource "aws_iam_role_policy_attachment" "attach_ebs" {
  role       = var.iam_instance_profile_role_name
  policy_arn = aws_iam_policy.attach_ebs.arn
}
