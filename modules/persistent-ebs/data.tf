data "aws_caller_identity" "current" {
}

data "aws_partition" "current" {
}

data "aws_iam_policy_document" "attach_ebs_policy_doc" {
  statement {
    sid    = ""
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]

    resources = concat(["arn:${data.aws_partition.current.partition}:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:instance/*"],
    [for x in aws_ebs_volume.main.*.id : "arn:${data.aws_partition.current.partition}:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:volume/${x}"])
  }
}
