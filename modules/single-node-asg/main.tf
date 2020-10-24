/**
 * ## Single-Node Auto-Scaling Group
 *
 * This module uses an EBS volume and an auto-scaling group with a single-node
 * to establish a reliable and robust pattern for HA in various forms.
 *
 * NOTE: This module assumes that all the dependencies for the
 * `../init-snippet-attach-ebs-volume` module are satisfied
 * by the `init_prefix`.
 * In particular, this means that the aws cli tool and ec2metadata are installed.
 *
 */

# Data source for the AWS subnet we deploy the EC2 instances into
data "aws_subnet" "server-subnet" {
  id = var.subnet_id
}

# To centralize and make obvious, these values, and the names for AWS resources
locals {
  # To give us a short-hand refernce to the AZ
  az = data.aws_subnet.server-subnet.availability_zone

  # The "name_prefix" we provide to the persistent-ebs module
  data_volume_name_prefix = "${var.name_prefix}-${var.name_suffix}-data"

  # The `name_prefix` we provide to the `iam-instance-profile` module
  # The persistent-ebs module appends the AZ to the data node name, other modules don't do that
  name_prefix_with_az = "${var.name_prefix}-${var.name_suffix}-${local.az}"
}

# Create an IAM Instance profile we can use on EC2, associated with the ASG
module "instance_profile" {
  source      = "../iam-instance-profile"
  name_prefix = local.name_prefix_with_az
}

# Create a single EBS volume that can be used in a single/specific AZ, for the ASG
module "service-data" {
  source      = "../persistent-ebs"
  name_prefix = local.data_volume_name_prefix
  region      = var.region
  az          = local.az
  size        = var.data_volume_size
  iops        = var.data_volume_iops
  volume_type = var.data_volume_type
  encrypted   = var.data_volume_encrypted
  kms_key_id  = var.data_volume_kms_key_id
  snapshot_id = var.data_volume_snapshot_id

  # EBS module will create an IAM policy and associate with this role
  iam_instance_profile_role_name = module.instance_profile.iam_role_name
}

resource "aws_eip" "eip" {
  count = var.assign_eip ? 1 : 0
  vpc   = true
}

resource "aws_iam_role_policy_attachment" "associate_eip" {
  role       = module.instance_profile.iam_role_name
  policy_arn = aws_iam_policy.associate_eip_policy.arn
}

resource "aws_iam_policy" "associate_eip_policy" {
  name   = "associate_address"
  policy = data.aws_iam_policy_document.associate_eip_policy_doc.json
}

data "aws_iam_policy_document" "associate_eip_policy_doc" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "ec2:AssociateAddress"
    ]
    resources = ["*"]
  }
}

# Create an ASG with just 1 EC2 instance
module "server" {
  source = "../asg"

  ami       = var.ami
  elb_names = var.load_balancers
  key_name  = var.key_name
  # The IAM Instance Profile w/ attach_ebs role
  iam_profile   = module.instance_profile.iam_profile_id
  instance_type = var.instance_type
  # 1 EC2 instance <> 1 EBS volume
  max_nodes       = 1
  min_nodes       = 1
  placement_group = var.placement_group
  public_ip       = var.assign_eip ? false : var.public_ip
  # the prefix and suffix names are combined in
  # the `asg` module to create the full name
  name_prefix        = var.name_prefix
  name_suffix        = "${var.name_suffix}-${local.az}"
  root_volume_type   = var.root_volume_type
  root_volume_size   = var.root_volume_size
  security_group_ids = var.security_group_ids
  subnet_ids         = [var.subnet_id]

  alb_target_group_arns = var.alb_target_group_arns

  user_data = <<END_INIT
#!/bin/bash
# exec > /tmp/init.log
# exec 2> /tmp/init-err.log
# set -x
apt update
${var.init_prefix}
${module.init-install-awscli.init_snippet}
while ! ${var.assign_eip ? "aws ec2 associate-address --instance-id \"$(ec2metadata --instance-id)\" --region \"${var.region}\" --allocation-id \"${element(aws_eip.eip.*.id, 0)}\"" : "true"}; do
  sleep 1
done
${module.init-attach-ebs.init_snippet}
${var.init_suffix}
END_INIT

}

# Render init snippet - boxed module to attach the EBS volume to the node
module "init-attach-ebs" {
  source    = "../init-snippet-attach-ebs-volume"
  region    = var.region
  volume_id = module.service-data.volume_id
}

module "init-install-awscli" {
  source = "../init-snippet-install-awscli"
}
