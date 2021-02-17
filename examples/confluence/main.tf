variable "region" {
  type        = string
  description = "AWS region to run the example"
}
variable "ssh_key" {
  type        = string
  description = "AWS SSH key name for instance"
}
variable "db_password" {
  type        = string
  description = "Password for RDS"
}
variable "base_domain" {
  type        = string
  description = "Base domain name for internal and external FQDN, with the last dot"
}

data "aws_availability_zones" "azs" {}

data "aws_route53_zone" "sandbox" {
  name         = var.base_domain
  private_zone = false
}

module "vpc" {
  source               = "fpco/foundation/aws//modules/vpc-scenario-2"
  azs                  = data.aws_availability_zones.azs.names
  cidr                 = "192.168.0.0/16"
  name_prefix          = "confluence"
  private_subnet_cidrs = ["192.168.100.0/24", "192.168.101.0/24"]
  public_subnet_cidrs  = ["192.168.0.0/24", "192.168.1.0/24"]
  region               = var.region
}

module "centos" {
  source  = "fpco/foundation/aws//modules/ami-centos"
  release = "7"
}

module "asg-sg" {
  source      = "fpco/foundation/aws//modules/security-group-base"
  name        = "asg-sg"
  description = "SG for ASG"
  vpc_id      = module.vpc.vpc_id
}

module "asg-to-world" {
  source            = "fpco/foundation/aws//modules/open-egress-sg"
  security_group_id = module.asg-sg.id
}

module "ssh-port-sg-rule" {
  source            = "fpco/foundation/aws//modules/single-port-sg"
  security_group_id = module.asg-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  port              = 22
  description       = "SSH from anywhere, for debug."
}

module "asg-int-alb-http-port-sg-rule" {
  source                   = "git::ssh://git@github.com/fpco/terraform-aws-foundation//modules/single-port-sg-src?ref=spsg"
  security_group_id        = module.asg-sg.id
  port                     = 80
  description              = "HTTP ingress for int ALB"
  source_security_group_id = module.int-alb.security_group_id
}

module "asg-ext-alb-http-port-sg-rule" {
  source                   = "git::ssh://git@github.com/fpco/terraform-aws-foundation//modules/single-port-sg-src?ref=spsg"
  security_group_id        = module.asg-sg.id
  port                     = 80
  description              = "HTTP ingress for ext ALB"
  source_security_group_id = module.ext-alb.security_group_id
}

module "asg" {
  source             = "fpco/foundation/aws//modules/single-node-asg"
  ami                = module.centos.id
  instance_type      = "m5.xlarge"
  key_name           = var.ssh_key
  name_prefix        = "confluence"
  name_suffix        = ""
  region             = var.region
  security_group_ids = [module.asg-sg.id]
  subnet_id          = module.vpc.private_subnet_ids[0]
  public_ip          = false
  data_volume_size   = 50
  init_prefix        = <<EOF
yum install -y python3-pip
pip3 install awscli
${module.install-docker-compose.init_snippet}
EOF
  init_suffix        = <<EOF
mkdir -p /data
mkfs.xfs /dev/xvdf
mount /dev/xvdf /data
mkdir -p /data/confluence
cat > /tmp/docker-compose.yml <<EOCAT
${data.template_file.docker_compose.rendered}
EOCAT
cd /tmp
docker-compose up -d
# rm docker-compose.yml
EOF
}

data "template_file" "docker_compose" {
  template = file("${path.module}/docker-compose.tpl")
  vars = {
    http_port = 80
    db_host   = module.rds.endpoint
    db_db     = "confluence"
    db_user   = "confluence"
    db_pass   = var.db_password
  }
}

module "data-backup" {
  source          = "fpco/foundation/aws//modules/dlm-lifecycle-policy"
  name_prefix     = "confluence"
  ebs_target_tags = { Name = module.asg.data_volume_name_tag }
}

module "install-docker-compose" {
  source = "fpco/foundation/aws//modules/init-snippet-install-docker-yum"
}

module "rds-sg" {
  source      = "fpco/foundation/aws//modules/security-group-base"
  name        = "rds-sg"
  description = "SG for RDS"
  vpc_id      = module.vpc.vpc_id
}

module "rds_sg_rule" {
  source                   = "git::ssh://git@github.com/fpco/terraform-aws-foundation//modules/single-port-sg-src?ref=spsg"
  security_group_id        = module.rds-sg.id
  port                     = 5432
  description              = "PGSQL ingress for RDS"
  source_security_group_id = module.asg-sg.id
}

module "rds" {
  source            = "fpco/foundation/aws//modules/rds"
  db_engine         = "postgres"
  db_instance_type  = "db.m5.xlarge"
  db_name           = "confluence"
  db_password       = var.db_password
  db_storage_size   = 20
  db_storage_type   = "gp2"
  db_username       = "confluence"
  engine_version    = "11"
  name_prefix       = "confluence"
  security_group_id = module.rds-sg.id
  subnet_ids        = module.vpc.private_subnet_ids
}

module "int-alb" {
  source      = "fpco/foundation/aws//modules/alb"
  vpc_id      = module.vpc.vpc_id
  name_prefix = "confluence-int"
  subnet_ids  = module.vpc.public_subnet_ids
}

module "int-alb-http-port-sg-rule" {
  source            = "fpco/foundation/aws//modules/single-port-sg"
  security_group_id = module.int-alb.security_group_id
  cidr_blocks       = ["192.168.0.0/16"]
  port              = 80
  description       = "HTTP ingress for ALB"
}

module "int-alb-https-port-sg-rule" {
  source            = "fpco/foundation/aws//modules/single-port-sg"
  security_group_id = module.int-alb.security_group_id
  cidr_blocks       = ["192.168.0.0/16"]
  port              = 443
  description       = "HTTPS ingress for ALB"
}

module "int-alb-to-asg" {
  source            = "fpco/foundation/aws//modules/open-egress-sg"
  security_group_id = module.int-alb.security_group_id
}

module "int-forwarder" {
  source         = "fpco/foundation/aws//modules/alb-default-forward"
  lb_arn         = module.int-alb.lb_arn
  lb_port        = 443
  name_prefix    = "confluence-int-https"
  protocol       = "HTTPS"
  service_port   = 80
  vpc_id         = module.vpc.vpc_id
  https_cert_arn = aws_acm_certificate_validation.validation.certificate_arn
}

module "int-redirector" {
  source     = "fpco/foundation/aws//modules/alb-redirect"
  lb_arn     = module.int-alb.lb_arn
  http_port  = 80
  https_port = 443
}

module "ext-alb" {
  source      = "fpco/foundation/aws//modules/alb"
  vpc_id      = module.vpc.vpc_id
  name_prefix = "confluence-ext"
  subnet_ids  = module.vpc.public_subnet_ids
  internal    = false
}

module "ext-alb-http-port-sg-rule" {
  source            = "fpco/foundation/aws//modules/single-port-sg"
  security_group_id = module.ext-alb.security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  port              = 80
  description       = "HTTP ingress for ALB"
}

module "ext-alb-https-port-sg-rule" {
  source            = "fpco/foundation/aws//modules/single-port-sg"
  security_group_id = module.ext-alb.security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  port              = 443
  description       = "HTTPS ingress for ALB"
}

module "ext-alb-to-asg" {
  source            = "fpco/foundation/aws//modules/open-egress-sg"
  security_group_id = module.ext-alb.security_group_id
}

module "ext-forwarder" {
  source         = "fpco/foundation/aws//modules/alb-default-forward"
  lb_arn         = module.ext-alb.lb_arn
  lb_port        = 443
  name_prefix    = "confluence-ext-https"
  protocol       = "HTTPS"
  service_port   = 80
  vpc_id         = module.vpc.vpc_id
  https_cert_arn = aws_acm_certificate_validation.validation.certificate_arn
}

module "ext-redirector" {
  source     = "fpco/foundation/aws//modules/alb-redirect"
  lb_arn     = module.ext-alb.lb_arn
  http_port  = 80
  https_port = 443
}

resource "aws_autoscaling_attachment" "asg_int_alb" {
  autoscaling_group_name = module.asg.asg_name
  alb_target_group_arn   = module.int-forwarder.target_group_arn
}

resource "aws_autoscaling_attachment" "asg_ext_alb" {
  autoscaling_group_name = module.asg.asg_name
  alb_target_group_arn   = module.ext-forwarder.target_group_arn
}

resource "aws_route53_record" "int" {
  zone_id = data.aws_route53_zone.sandbox.zone_id
  name    = "c-i.${data.aws_route53_zone.sandbox.name}"
  type    = "A"
  alias {
    name                   = module.int-alb.lb_dns_name
    zone_id                = module.int-alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ext" {
  zone_id = data.aws_route53_zone.sandbox.zone_id
  name    = "c-e.${data.aws_route53_zone.sandbox.name}"
  type    = "A"
  alias {
    name                   = module.ext-alb.lb_dns_name
    zone_id                = module.ext-alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = aws_route53_record.ext.fqdn
  subject_alternative_names = [aws_route53_record.int.fqdn]
  validation_method         = "DNS"
}

resource "aws_route53_record" "cert_validation_ext" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.sandbox.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "cert_validation_int" {
  name    = aws_acm_certificate.cert.domain_validation_options.1.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.1.resource_record_type
  zone_id = data.aws_route53_zone.sandbox.id
  records = [aws_acm_certificate.cert.domain_validation_options.1.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_ext.fqdn, aws_route53_record.cert_validation_int.fqdn]
}
