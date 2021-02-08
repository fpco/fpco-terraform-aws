locals {
  name_prefix_with_suffix    = "${var.name_prefix}-${var.name_suffix}"
  name_prefix_without_suffix = "${var.name_prefix}"

  name_prefix = "${var.name_suffix != "" ? local.name_prefix_without_suffix : local.name_prefix_with_suffix}"

}
