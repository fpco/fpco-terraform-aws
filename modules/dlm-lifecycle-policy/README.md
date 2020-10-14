## Data Lifecycle Manager (DLM) lifecycle policy for managing snapshots

This module creates the policy that manage the creation of EBS snapshots through AWS Data Lifecycle Manager, the policy let you manage the schedule of the snapshot as well as the number of snapshots.

### Example how to use

Define variables

```
module "dlm-lifecycle-policy" {
  source = "github.com/fpco/terraform-aws-foundation/modules/dlm-lifecycle-policy"

  name_prefix             = project-name-backup
  description             = "DLM lifecycle policy"
  ebs_target_tags         = { "ebs-to-take-snapshot-name-ec2-volume" = "true" }
  policy_name             = "Two weeks of daily snapshots"
  policy_interval         = 24
  policy_times            = ["23:45"]
  policy_copy_tags        = false
  policy_retain_rule      = 14
  policy_tags_to_add      = "${merge(map("Name", "${var.name}-dlm", "SnapshotCreator", "DLM lifecycle"))}"
  resource_type           = ["VOLUME"]
  iam_role_name           = "dlm-lifecycle-role"
}
```
