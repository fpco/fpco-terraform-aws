/**
 * ## Run Tests on the VPC Scenario 2 Module
 *
 *
 */

variable "extra_tags" {
  description = "Extra tags that will be added to aws_subnet resources"
  default     = {}
}

variable "name" {
  description = "name of the project, use as prefix to names of resources created"
  default     = "test-project"
}

variable "region" {
  description = "Region where the project will be deployed"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "Top-level CIDR for the whole VPC network space"
  default     = "10.23.0.0/16"
}

variable "ssh_pubkey" {
  description = "File path to SSH public key"
  default     = "./id_rsa.pub"
}

variable "ssh_key" {
  description = "File path to SSH public key"
  default     = "./id_rsa"
}

variable "public_subnet_cidrs" {
  default     = ["10.23.11.0/24", "10.23.12.0/24", "10.23.13.0/24"]
  description = "A list of public subnet CIDRs to deploy inside the VPC"
}

variable "private_subnet_cidrs" {
  default     = ["10.23.21.0/24", "10.23.22.0/24", "10.23.23.0/24"]
  description = "A list of private subnet CIDRs to deploy inside the VPC"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source      = "../../modules/vpc-scenario-2"
  name_prefix = "${var.name}"
  region      = "${var.region}"
  cidr        = "${var.vpc_cidr}"
  azs         = ["${slice(data.aws_availability_zones.available.names, 0, 3)}"]

  extra_tags = {
    kali = "ma"
  }

  public_subnet_cidrs  = ["${var.public_subnet_cidrs}"]
  private_subnet_cidrs = ["${var.private_subnet_cidrs}"]
}

module "ubuntu-xenial-ami" {
  source  = "../../modules/ami-ubuntu"
  release = "14.04"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.name}"
  public_key = "${file(var.ssh_pubkey)}"
}

# Security group for the elastic load balancer
module "elb-sg" {
  source      = "../../modules/security-group-base"
  description = "Allow public access to ELB in ${var.name}"
  name        = "${var.name}-elb"
  vpc_id      = "${module.vpc.vpc_id}"
}

# security group rule for elb open egress (outbound from nodes)
module "elb-open-egress-rule" {
  source            = "../../modules/open-egress-sg"
  security_group_id = "${module.elb-sg.id}"
}

# Security group for the web instance, only accessible from ELB
module "web-sg" {
  source      = "../../modules/security-group-base"
  description = "Allow HTTP and SSH to web instance in ${var.name}"
  name        = "${var.name}-web"
  vpc_id      = "${module.vpc.vpc_id}"
}

# allow HTTP from ELB to web instances
module "web-http-elb-sg-rule" {
  source            = "../../modules/single-port-sg"
  port              = "3000"
  description       = "Allow ELB HTTP to web app on port 3000"
  cidr_blocks       = ["${module.vpc.public_cidr_blocks}"]
  security_group_id = "${module.web-sg.id}"
}

# open egress for web instances (outbound from nodes)
module "web-open-egress-sg-rule" {
  source            = "../../modules/open-egress-sg"
  security_group_id = "${module.web-sg.id}"
}

# Load Balancer
resource "aws_elb" "web" {
  name = "${var.name}-public-elb"

  health_check {
    healthy_threshold   = 2
    interval            = 15
    target              = "TCP:3000"
    timeout             = "5"
    unhealthy_threshold = 10
  }

  # public, or private to VPC?
  internal = false

  # route HTTPS to services app on port 3000
  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # Ensure we allow incoming traffic to the ELB, HTTP/S
  security_groups = ["${module.elb-sg.id}"]

  # ELBs in the public subnets, separate from the web ASG in private subnets
  subnets = ["${module.vpc.public_subnet_ids}"]
}

module "web" {
  source           = "../../modules/asg"
  ami              = "${module.ubuntu-xenial-ami.id}"
  azs              = "${slice(data.aws_availability_zones.available.names, 0, 3)}"
  name_prefix      = "${var.name}-web"
  elb_names        = ["${aws_elb.web.name}"]
  instance_type    = "t2.nano"
  desired_capacity = "${length(module.vpc.public_subnet_ids)}"
  max_nodes        = "${length(module.vpc.public_subnet_ids)}"
  min_nodes        = "${length(module.vpc.public_subnet_ids)}"
  public_ip        = false
  key_name         = "${aws_key_pair.main.key_name}"
  subnet_ids       = ["${module.vpc.private_subnet_ids}"]

  security_group_ids = ["${module.web-sg.id}"]

  root_volume_type = "gp2"
  root_volume_size = "8"

  user_data = <<END_INIT
#!/bin/bash
echo "hello!"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
apt-get update
apt-get install -y docker-ce

docker run                   \
    --restart=always         \
    -d                       \
    -v /var/log/cloud-init-output.log:/var/www/html/cloud-init-output.log \
    -p $(ec2metadata --local-ipv4):3000:3000 \
    yesodweb/warp            \
    warp --docroot /var/www/html

END_INIT
}

output "elb_dns" {
  value       = "${aws_elb.web.dns_name}"
  description = "make the ELB accessible on the outside"
}
