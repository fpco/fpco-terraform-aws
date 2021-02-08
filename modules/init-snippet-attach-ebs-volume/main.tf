/**
 * ## Init Snippet: Attach EBS Volume
 *
 * Create an init snippet that will attach an EBS volume to the instance.
 * This snippet requires that the instance has an IAM instance profile which
 * grants it the access needed to find and attach the EBS volume. There are
 * other modules in this repo which can create EBS volumes with IAM profiles
 * for each volume. Attaching the EBS volume will loop until it succeeds.
 *
 */

# render init script for a cluster using our generic template
data "template_file" "init_snippet" {
  count = length(var.volume_ids)

  template = file("${path.module}/snippet.tpl")

  vars = {
    device_path   = var.device_paths[count.index]
    log_prefix    = var.log_prefix
    log_level     = var.log_level
    region        = var.region
    volume_id     = var.volume_ids[count.index]
    wait_interval = var.wait_interval
  }
}

data "template_file" "instance_id" {
  template = file("${path.module}/instance_id.tpl")
}

output "init_snippet" {
  value = <<EOF
${var.init_prefix}
${data.template_file.instance_id.rendered}
${join("\n", data.template_file.init_snippet.*.rendered)}
${var.init_suffix}
EOF
}

