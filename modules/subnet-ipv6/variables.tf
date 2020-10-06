variable "name_prefix" {
  description = "Name to prefix subnets with"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "cidr_block" {
  description = "The IPv4 CIDR block for the subnet"
  type        = string
}

variable "az" {
  description = "The Availaiblity Zones to create the subnet in"
  type        = string
}

variable "extra_tags" {
  default     = {}
  description = "Extra tags that will be added to aws_subnet resources"
  type        = map(string)
}

# default to creating a public subnet
variable "public" {
  default     = true
  description = "Boolean, maps to the map_public_ip_on_launch variable"
  type        = bool
}

variable "vpc_ipv6_cidr_block" {
  description = "The IPv6 cidr block for the vpc"
  type        = string
}

variable "ipv6_newbits" {
  description = "The number of additional bits with which to extend the prefix"
  type = number
  default = 8
}

variable "ipv6_netsum" {
  description = "a whole number that can be represented as a binary integer with no more than newbits binary digits"
  type = number
  default =  162
}
