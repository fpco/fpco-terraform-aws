output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "dhcp_options_id" {
  value       = aws_vpc_dhcp_options.main.id
  description = "ID of the DHCP options resource"
}

# It would be great if Terraform had an Option or Maybe type
# Otherwise this will output an empty default value if the IPv6 option is not
# set to true
output "ipv6_cidr_block" {
  value       =  (var.assign_generated_ipv6_cidr_block ? aws_vpc.main.ipv6_cidr_block : "")
  description = "Optional IPv6 CIDR block output for the VPC"
}
