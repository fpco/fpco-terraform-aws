variable "name_prefix" {
  description = "Prefix that will be added to names of all resources"
}

variable "name_suffix" {
  description = "suffix to include when naming the various resources"
  default     = "kube-load-balancer"
}

variable "vpc_id" {
  description = "VPC id for the security group"
}

variable "api_port" {
  description = "TCP port the load balancer should be configured to listen on"
  default     = "443"
}

variable "cidr_blocks_api" {
  description = "list of CIDR blocks that should have access to the kube API"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

