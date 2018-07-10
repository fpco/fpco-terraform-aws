/**
 * ## Test Gitlab on a Single-Node ASG
 * 
 * Run a Gitlab on a single EC2 instance.
 * This instance will be part of a single-node autoscaling group
 * that shares an EBS volume to store data.
 *
 * Note that there is a peculiarity with the EBS volume in that it
 * requires some manual setup the very first time to make it available
 * for use (unless a snapshot id is supplied):
 *
 * parted --script /dev/xvdf -- mklabel msdos
 * parted --script /dev/xvdf -- mkpart primary 0 -1
 * mkfs -t ext4 -F /dev/xvdf1
 * e2label /dev/xvdf1 gitlab
 *
 * After running the above code to initialise the EBS, terminate the instance
 * and the autoscaling group will bring up a new instance that will be running
 * gitlab once it is done initialising.
 * 
 */

variable "name" {
  default = "gitlab-asg-test"
}

variable "region" {
  default = "us-east-1"
}

variable "ssh_pubkey" {
  default     = "./id_rsa.pub"
  description = "The path to the SSH pub key to use"
}

variable "dns_zone_name" {
  description = "The name of the DNS zone on Route53 (example.com), to create records in for gitlab"
  type        = "string"
}

variable "ssl_arn" {
  description = "The ARN of the SSL cert, see 'make upload-tls-certs'"
  type        = "string"
}

variable "gitlab_name" {
  description = "To generate the DNS record for gitlab, prefix the zone"
  default     = "gitlab"
  type        = "string"
}

variable "gitlab_registry_name" {
  description = "To generate the DNS record for the docker registry, prefix the zone"
  default     = "registry"
  type        = "string"
}

variable "root_volume_size" {
  default     = "30"
  description = "GB of root data volume for the instance, make it larger than usual for docker builds"
}

variable "registry_bucket_name" {
  description = "The name of the S3 bucket to write docker images to"
  type        = "string"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zones" "available" {}

module "ubuntu-xenial-ami" {
  source  = "../../modules/ami-ubuntu"
  release = "16.04"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.name}"
  public_key = "${file(var.ssh_pubkey)}"
}

# S3 bucket for the Docker Registry (running in gitlab) to store Docker Images
module "docker-registry-s3-storage" {
  source      = "../../tf-modules/s3-remote-state"
  bucket_name = "${var.registry_bucket_name}"
  versioning  = "false"
  principals  = []
}

module "docker-registry-s3-full-access" {
  source       = "../../tf-modules/s3-full-access-policy"
  name         = "${var.name}-docker-registry-s3-full-access"
  bucket_names = ["${module.docker-registry-s3-storage.bucket_id}"]
}

resource "aws_iam_role_policy_attachment" "s3-full-access-attachment" {
  role       = "${module.gitlab-asg.asg_iam_role_name}"
  policy_arn = "${module.docker-registry-s3-full-access.arn}"
}

resource "aws_elb" "gitlab" {
  name            = "${var.name}"
  subnets         = ["${module.vpc.public_subnet_ids[0]}"]
  security_groups = ["${aws_security_group.gitlab-elb.id}"]

  listener {
    instance_port     = 8022
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"

    #ssl_certificate_id = "${var.ssl_arn}"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${var.ssl_arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "gitlab-elb" {
  name        = "gitlab-elb"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for the gitlab ELB"
}

module "elb-http-rule" {
  source            = "../../modules/single-port-sg"
  port              = 80
  description       = "Allow ingress for HTTP, port 80 (TCP), thru the ELB"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab-elb.id}"
}

module "elb-https-rule" {
  source            = "../../modules/single-port-sg"
  port              = 443
  description       = "Allow ingress for HTTPS, port 443 (TCP), thru the ELB"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab-elb.id}"
}

module "elb-gitlab-ssh-rule" {
  source            = "../../modules/single-port-sg"
  port              = 22
  description       = "Allow ingress for Git over SSH, port 22 (TCP), thru the ELB"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab-elb.id}"
}

module "elb-open-egress-rule" {
  source            = "../../modules/open-egress-sg"
  security_group_id = "${aws_security_group.gitlab-elb.id}"
}

module "gitlab-asg" {
  source        = "../../modules/single-node-asg"
  name_prefix   = "${var.name}"
  name_suffix   = "gitlab-server"
  region        = "${var.region}"
  key_name      = "${aws_key_pair.main.key_name}"
  ami           = "${module.ubuntu-xenial-ami.id}"
  instance_type = "t2.medium"
  subnet_id     = "${module.vpc.public_subnet_ids[0]}"

  load_balancers        = ["${aws_elb.gitlab.name}"]
  security_group_ids    = ["${aws_security_group.gitlab.id}"]
  root_volume_size      = "${var.root_volume_size}"
  data_volume_encrypted = false

  init_prefix = <<END_INIT
apt-get update
${module.init-install-awscli.init_snippet}
${module.init-install-ops.init_snippet}
END_INIT

  init_suffix = <<END_INIT
mkdir -p /gitlab
mount /dev/xvdf1 /gitlab

cp /etc/fstab /etc/fstab.orig
echo "LABEL=gitlab            /gitlab  ext4   defaults,nofail     0 2" >> /etc/fstab

apt-get install -y docker docker.io
${module.init-gitlab-docker.init_snippet}
${module.init-gitlab-runner.init_snippet}
END_INIT
}

module "init-install-awscli" {
  source = "../../modules/init-snippet-install-awscli"
}

module "init-install-ops" {
  source = "../../modules/init-snippet-install-ops"
}

module "init-gitlab-docker" {
  source        = "../../modules/init-snippet-gitlab-docker"
  gitlab_domain = "${var.dns_zone_name}"

  # write docker images to this S3 bucket (created separate from this env)
  registry_bucket_name   = "${var.registry_bucket_name}"
  registry_bucket_region = "${var.region}"
}

module "init-gitlab-runner" {
  source = "../../tf-modules/init-snippet-exec"

  init = <<END_INIT
mkdir /etc/gitlab-runner
cp /gitlab/gitlab-runner-config.toml /etc/gitlab-runner/config.toml
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh |  bash
apt-get install -y gitlab-runner
END_INIT
}

module "vpc" {
  source              = "../../modules/vpc-scenario-1"
  azs                 = ["${slice(data.aws_availability_zones.available.names, 0, 1)}"]
  name_prefix         = "${var.name}"
  cidr                = "192.168.0.0/16"
  public_subnet_cidrs = ["192.168.0.0/16"]
  region              = "${var.region}"
}

resource "aws_security_group" "gitlab" {
  name        = "gitlab-asg"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Security group for the single-node autoscaling group"
}

module "ssh-rule" {
  source            = "../../modules/ssh-sg"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab.id}"
}

module "http-rule" {
  source            = "../../modules/single-port-sg"
  port              = 80
  description       = "Allow ingress for HTTP, port 80 (TCP)"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab.id}"
}

module "https-rule" {
  source            = "../../modules/single-port-sg"
  port              = 443
  description       = "Allow ingress for HTTPS, port 443 (TCP)"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab.id}"
}

module "gitlab-ssh-rule" {
  source            = "../../modules/single-port-sg"
  port              = 8022
  description       = "Allow ingress for Git over SSH, port 8022 (TCP)"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gitlab.id}"
}

module "open-egress-rule" {
  source            = "../../modules/open-egress-sg"
  security_group_id = "${aws_security_group.gitlab.id}"
}

##################
## DNS setup

data "aws_route53_zone" "selected" {
  name = "${var.dns_zone_name}"
}

resource "aws_route53_record" "gitlab" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.gitlab_name}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.gitlab.dns_name}"]
}

resource "aws_route53_record" "registry" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.gitlab_registry_name}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elb.gitlab.dns_name}"]
}

##################
## Outputs

output "region" {
  value       = "${var.region}"
  description = "region deployed to"
}

output "gitlab_asg_name" {
  value       = "${var.name}-gitlab-asg-${element(data.aws_availability_zones.available.names, 0)}"
  description = "name of the Gitlab autoscaling group"
}

output "gitlab_url" {
  value       = "${aws_route53_record.gitlab.name}"
  description = "URL to gitlab"
}

output "registry_url" {
  value       = "${aws_route53_record.registry.name}"
  description = "URL to docker image registry"
}

// URL to S3 bucket where Docker images are stored
output "registry_bucket_url" {
  value = "${module.docker-registry-s3-storage.url}"
}

// Name of the S3 bucket where Docker images are stored
output "registry_bucket_name" {
  value = "${module.docker-registry-s3-storage.bucket_id}"
}
