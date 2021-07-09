variable "internal" {
  default     = true
  type        = bool
  description = "Whether the LB should face Internet."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets for LBs to live in."
}

variable "ports" {
  type        = list(tuple([number, number]))
  description = "The port pair of TCP services. The first of each pair is the port opened on NLB, that clients access. The second of each pair is the port opened on service. The parameter is in form of \"[[80, 8000], [8123, 8123]]\"."
}

variable "vpc_id" {
  type        = string
  description = "The identifier of the VPC in which to create the target groups."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for aws_lb resource."
}

variable "name_prefix" {
  type = string
}	
