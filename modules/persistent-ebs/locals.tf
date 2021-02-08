locals {
  volume_default = {
    type        = "gp2"
    iops        = 0
    size        = 15
    encrypted   = true
    kms_key_id  = ""
    snapshot_id = ""
  }
  volumes_default = [for x in var.volumes : merge(local.volume_default, x)]
}
