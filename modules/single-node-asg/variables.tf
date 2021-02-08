variable "name_prefix" {
  description = "Prefix for naming resources, usually project-related"
  type        = string
}

variable "key_name" {
  description = "The name of the (AWS) SSH key to associate with the instance"
  type        = string
}

variable "ami" {
  description = "The base AMI for each AWS instance created"
  type        = string
}

variable "instance_type" {
  description = "The type of AWS instance (size)"
  type        = string
}

variable "placement_group" {
  default     = ""
  description = "The `id` of the `aws_placement_group` to associate with the ASG"
  type        = string
}

variable "name_suffix" {
  description = "suffix to include when naming the various resources, ignored if left as empty string"
  default     = ""
  type        = string
}

variable "alb_target_group_arns" {
  default     = []
  description = "list of target_group for application load balancer to associate with the ASG (by ARN)"
  type        = list(string)
}

variable "root_volume_type" {
  default     = "gp2"
  description = "Type of EBS volume to use for the root block device"
  type        = string
}

variable "root_volume_size" {
  default     = 8
  description = "Size (in GB) of EBS volume to use for the root block device"
  type        = number
}

variable "init_prefix" {
  default     = ""
  description = "init shell to run before setting VOLUME_ID and REGION exports"
  type        = string
}

variable "init_suffix" {
  default     = ""
  description = "init shell to run after setting VOLUME_ID and REGION exports"
  type        = string
}

variable "public_ip" {
  default     = true
  description = "Boolean flag to enable/disable `map_public_ip_on_launch` in the launch configuration"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to use, depends on the availability zone"
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
  description = "list of security groups (by ID) to associate with the ASG"
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "load_balancers" {
  default     = []
  description = "The list of load balancers names to pass to the ASG module"
  type        = list(string)
}

variable "data_volumes" {
  type = list(map(any))
  description = "Definition of the data volumes. `name` and `device` are required."
}
