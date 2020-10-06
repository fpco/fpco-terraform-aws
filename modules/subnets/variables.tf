variable "name_prefix" {
  description = "Name to prefix subnets with"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where subnets will be created"
  type        = string
}

variable "cidr_blocks" {
  description = "A list of CIDR blocks for the subnets"
  type        = list(string)
}

variable "azs" {
  description = "A list of Availaiblity Zones to create subnets in"
  type        = list(string)
}

variable "extra_tags" {
  default     = {}
  description = "Extra tags that will be added to aws_subnet resources"
  type        = map(string)
}

# default to creating public subnets
variable "public" {
  default     = true
  description = "Boolean, maps to the map_public_ip_on_launch variable"
  type        = bool
}
