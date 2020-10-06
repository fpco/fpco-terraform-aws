/**
 * ## Gateway and Routing for Public Subnets
 *
 * This module provides an `aws_internet_gateway` and route table to use that
 * gateway to access the public internet (`0.0.0.0/0`). The module also accepts
 * a list of IDs for public subnets that should use the routing table.
 *
 */

resource "aws_internet_gateway" "public" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = var.name_prefix
    },
    var.extra_tags,
  )
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  tags = merge(
    {
      "Name" = "${var.name_prefix}-public"
    },
    var.extra_tags,
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(var.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
  depends_on             = [aws_route_table.public]
}

resource "aws_route" "public6" {
  # TODO make this optional or control with count
  route_table_id         = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id             = aws_internet_gateway.public.id
  depends_on             = [aws_route_table.public]
}
