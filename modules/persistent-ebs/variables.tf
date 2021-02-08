variable "name_prefix" {
  description = "The name of the environment to deploy to (beta/prod/etc)"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to"
  default     = ""
  type        = string
}

variable "az" {
  description = "The AWS Availability Zone (AZ) to create the instance in"
  type        = string
}

variable "extra_tags" {
  default     = {}
  description = "Map with extra tags to be applied to all ebs volumes"
  type        = map(string)
}

variable "iam_instance_profile_role_name" {
  description = "The role to attach policy needed by this module."
  type        = string
}

variable "volumes" {
  type = list(map(any))
### Note: what should be contained.
#    type        = string,
#    iops        = number,
#    size        = number,
#    encrypted   = bool,
#    kms_key_id  = string,
#    snapshot_id = string,
#    name        = string
  description = "Definition of volumes. `name` is required."
  default     = []
}
