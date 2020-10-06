/**
 * ## Single Port Security Group Rule
 *
 * Create an `aws_security_group_rule` to allow ingress on some port.
 *
 */

variable "security_group_id" {
  description = "security group to attach the ingress rules to"
  type        = string
}

variable "cidr_blocks" {
  description = "List of CIDR block ranges that the SG allows ingress from"
  type        = list(string)
}

variable "ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR block ranges that the SG allows ingress from"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Use this string to add a description for the SG rule"
  type        = string
}

variable "port" {
  description = "The port to open"
  type        = string
}

variable "tcp" {
  description = "true/false to enables the tcp ingress"
  default     = "true"
  type        = string
}

variable "udp" {
  description = "true/false to enables the udp ingress"
  default     = "false"
  type        = string
}

locals {
  tcp = "${var.tcp ? 1 : 0}"
  udp = "${var.udp ? 1 : 0}"
}

# ingress rule for tcp, if enabled
resource "aws_security_group_rule" "tcp_ingress" {
  count             = local.tcp
  type              = "ingress"
  description       = "${var.description} (tcp)"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  ipv6_cidr_blocks  = var.ipv6_cidr_blocks
  security_group_id = var.security_group_id
}

# ingress rule for udp, if enabled
resource "aws_security_group_rule" "udp_ingress" {
  count             = local.udp
  type              = "ingress"
  description       = "${var.description} (udp)"
  from_port         = var.port
  to_port           = var.port
  protocol          = "udp"
  cidr_blocks       = var.cidr_blocks
  ipv6_cidr_blocks  = var.ipv6_cidr_blocks
  security_group_id = var.security_group_id
}
