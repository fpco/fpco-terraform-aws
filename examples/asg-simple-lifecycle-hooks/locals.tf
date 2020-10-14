locals {
  az_count = length(var.public_subnet_cidrs)
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    local.az_count)
}
