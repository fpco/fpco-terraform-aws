variable "name_prefix" {
}

variable "ami" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "min_server_count" {
  description = "Minimum number of EC2 instances running Kibana"
  default = 1
}

variable "max_server_count" {
  description = "Maximum number of EC2 instances running Kibana"
  default = 1
}

variable "desired_server_count" {
  description = "Desired number of EC2 instances running Kibana"
  default = 1
}

variable "vpc_id" {
  description = "VPC id where Kibana servers should be deployed in"
}

variable "private_subnet_ids" {
  description = "A list of private subnet ids to deploy Kibana servers in"
  type = "list"
}

variable "public_subnet_ids" {
  description = "A list of public subnet ids to deploy Kibana ELB in"
  type = "list"
}

variable "kibana_dns_name" {
  description = "DNS name for Kibana endpoint. For SSL Certificate in ACM, if different, set 'kibana_dns_ssl_name'"
}

variable "kibana_dns_ssl_name" {
  default = ""
  description = "DNS name for Kibana endpoint SSL. An SSL certificate is expected to be present in ACM for this domain. If left empty 'kibana_dns_name' will be checked instead."
}

variable "elasticsearch_url" {
  description = "Elasticsearch endpoint URL"
}

variable "key_name" {
  description = "SSH key name to use for connecting to all nodes"
}

variable "internal" {
  default = true
  description = "Set it to false if you want Kibana to be accessible by the outside world"
}

variable "extra_sg_ids" {
  default = []
  description = "Extra Security Group IDs that will be added to all instances running Kibana. This is a way to add extra services, SSH access for instance."
}

variable "extra_elb_sg_ids" {
  default = []
  description = "Extra Security Group IDs that will be added to Kibana Load Balancer"
}

variable "elb_ingress_cidrs" {
  default = []
  description = "CIDRs that are allowed to access Kibana web UI. By default only CIDR from `public_subnet_ids` are allowed"
}

variable "credstash_install_snippet" {
  description = "Ubuntu bash script snippet for installing credstash and its dependencies"
}

variable "credstash_get_cmd" {
  description = "Credstash get command with region and table values set."
}

