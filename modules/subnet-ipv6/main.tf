/**
 * ## AWS Subnet IPv6
 * Creates a single IPv6 ready subnet
 *
 */

resource "aws_subnet" "main" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  ipv6_cidr_block   = cidrsubnet(var.vpc_ipv6_cidr_block, var.ipv6_newbits, var.ipv6_netsum)
  availability_zone = var.az

  tags = merge(
    {
      "Name" = "${var.name_prefix}-${var.az}"
    },
    var.extra_tags,
  )

  map_public_ip_on_launch         = var.public
  assign_ipv6_address_on_creation = true
}
