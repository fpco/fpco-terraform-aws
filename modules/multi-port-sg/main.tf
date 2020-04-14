/**
 * ## Multiple Ports Security Group Rule
 *
 * Create an `aws_security_group_rule` to allow ingress on some ports.
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

variable "description" {
  description = "Use this string to add a description for the SG rule"
  type        = string
}

variable "tcp_ports" {
  description = "TCP ports to open"
  type        = set(string)
  default     = []
}

variable "udp_ports" {
  description = "UDP ports to open"
  type        = set(string)
  default     = []
}

# ingress rules for TCP
resource "aws_security_group_rule" "tcp-ingress" {
  for_each          = var.tcp_ports
  type              = "ingress"
  description       = "${var.description} (tcp)"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = var.security_group_id
}

# ingress rule for UDP, if any ports were specified
resource "aws_security_group_rule" "udp-ingress" {
  for_each          = var.udp_ports
  type              = "ingress"
  description       = "${var.description} (udp)"
  from_port         = each.value
  to_port           = each.value
  protocol          = "udp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = var.security_group_id
}
