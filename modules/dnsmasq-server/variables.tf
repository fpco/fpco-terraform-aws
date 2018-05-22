variable "ami" {
  description = "AMI to use for instances.  Tested with Ubuntu 16.04."
  type        = "string"
}

variable "aws_cloud" {
  description = "set to 'aws-us-gov' if using GovCloud, otherwise leave the default"
  default     = "aws"
  type        = "string"
}

variable "instance_type" {
  description = "Type of instance to run the DNS servers"
  default     = "t2.nano"
  type        = "string"
}

variable "subnet_ids" {
  description = "Subnets to run servers in"
  type        = "list"
}

variable "private_ips" {
  description = "Private IP addresses of servers, which must be within the subnets specified in 'subnet_ids' (in the same order).  These are specified explicitly since it's desirable to be able to replace a DNS server without its IP address changing.  Our convention is to use the first unreserved address in the subnet (which is to say, the '+4' address)."
  type        = "list"
}

variable "security_group_ids" {
  description = "Security groups to assign servers"
  type        = "list"
}

variable "key_name" {
  description = "SSH key-pair name to use for setup"
  type        = "string"
}

variable "ssh_user" {
  description = "username to use in SSH connection to update DNS config"
  default     = "ubuntu"
  type        = "string"
}

variable "ssh_key" {
  description = "File path to the private key for SSH"
  default     = "/dev/null"
  type        = "string"
}

variable "name_prefix" {
  description = "Name prefix of the instances (will append 'dns-master-XX')"
  type        = "string"
}

variable "name_format" {
  default     = "%s-dns-master-%02d"
  description = "naming scheme as a string, to use with the format() function"
  type        = "string"
}

variable "dnsmasq_conf" {
  description = "Complete content of '/etc/dnsmasq.conf'"
  default     = "#"
  type        = "string"
}

variable "pre_init" {
  description = "extra shell code to run, prior to the DNS setup"
  default     = "echo 'pre-dnsmasq init'"
  type        = "string"
}

variable "post_init" {
  description = "extra shell code to run, post DNS setup"
  default     = "echo 'post-dnsmasq init'"
  type        = "string"
}

variable "user_data" {
  description = "shell script code passed to `aws_instance.user_data`, separate from pre/post init"
  default     = ""
  type        = "string"
}

variable "alarm_actions" {
  description = "list of alarm actions to append to the default (optional)"
  default     = []
  type        = "list"
}

variable "root_volume_type" {
  default     = "gp2"
  description = "Type of EBS volume to use for the root block device"
  type        = "string"
}

variable "root_volume_size" {
  default     = "8"
  description = "Size (in GB) of EBS volume to use for the root block device"
  type        = "string"
}

variable "bastion_host" {
  default     = ""
  description = "maps to `bastion_host` attribute for the `ssh` `connection` to the `aws_instance` provisioners"
  type        = "string"
}

variable "bastion_user" {
  default     = ""
  description = "maps to `bastion_user` attribute for the `ssh` `connection` to the `aws_instance` provisioners"
  type        = "string"
}

variable "bastion_private_key" {
  default     = ""
  description = "maps to `bastion_private_key` attribute for the `ssh` `connection` to the `aws_instance` provisioners"
  type        = "string"
}
