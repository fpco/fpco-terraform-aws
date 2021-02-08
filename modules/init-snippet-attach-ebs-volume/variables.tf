variable "device_paths" {
  type        = list(string)
  description = "paths, to the device's path in /dev/"
  default     = []
}

variable "init_prefix" {
  default     = ""
  description = "initial init (shellcode) to prefix this snippet with"
  type        = string
}

variable "init_suffix" {
  default     = ""
  description = "init (shellcode) to append to the end of this snippet"
  type        = string
}

variable "log_level" {
  default     = "info"
  description = "default log level verbosity for apps that support it"
  type        = string
}

variable "log_prefix" {
  default     = "OPS: "
  description = "string to prefix log messages with"
  type        = string
}

variable "region" {
  description = "AWS region the volume is in"
  type        = string
}

variable "wait_interval" {
  default     = "5"
  description = "time (in seconds) to wait when looping to find the device"
  type        = number
}

variable "volume_ids" {
  description = "IDs of the EBS volumes to attach"
  type        = list(string)
  default     = []
}
