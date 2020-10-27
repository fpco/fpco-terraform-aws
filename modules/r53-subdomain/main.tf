/**
 * ## Route 53 Subdomain
 *
 * This module simplifies the code in creating a subdomain under an existing
 * domain.
 *
 */
variable "name" {
  description = "name (FQDN) of the subdomain"
  type        = string
}

variable "parent_zone_id" {
  description = "Zone ID of the parent domain"
  type        = string
}

variable "ttl" {
  description = "TTL for the NS records created"
  default     = 172800
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to associate a private zone with (leave blank for public zone), use assocations for linking multiple VPCs"
  default     = ""
  type        = string
}

resource "aws_route53_zone" "subdomain" {
  name   = var.name

  dynamic "vpc" {
    for_each = [var.vpc_id]

    content {
      vpc_id = var.vpc_id
    }
  }
}

resource "aws_route53_record" "subdomain-NS" {
  zone_id = var.parent_zone_id
  name    = var.name
  type    = "NS"
  ttl     = var.ttl

  records = [
    aws_route53_zone.subdomain.name_servers[0],
    aws_route53_zone.subdomain.name_servers[1],
    aws_route53_zone.subdomain.name_servers[2],
    aws_route53_zone.subdomain.name_servers[3],
  ]
}

output "zone_id" {
  description = "The ID of the DNS zone"
  value       = aws_route53_zone.subdomain.zone_id
}

output "zone_name" {
  description = "The name of the DNS zone"
  value       = aws_route53_zone.subdomain.name
}

output "zone_name_without_trailing_dot" {
  description = "The name of the DNS zone, without the trailing period"
  value = substr(
    aws_route53_zone.subdomain.name,
    0,
    length(aws_route53_zone.subdomain.name) - 1,
  )
}

