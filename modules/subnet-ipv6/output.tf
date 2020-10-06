output "id" {
  description = "The subnet id"
  value       = aws_subnet.main.id
}

output "cidr_block" {
  description = "The IPv4 CIDR block"
  value       = aws_subnet.main.cidr_block
}

output "ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = aws_subnet.main.ipv6_cidr_block
}

output "az" {
  value       = aws_subnet.main.availability_zone
  description = "The availability zones of the subnet"
}

output "vpc_id" {
  description = "ID of the VPC the subnet is in"
  value       = var.vpc_id
}

