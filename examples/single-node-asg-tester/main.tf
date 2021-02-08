locals {
  cidr                 = "192.168.0.0/16"
  private_subnet_cidrs = ["192.168.100.0/24", "192.168.101.0/24"]
  public_subnet_cidrs  = ["192.168.0.0/24", "192.168.1.0/24"]
  region = "ap-northeast-1"
}

data "aws_availability_zones" "azs" { }

module "vpc" {
  source               = "fpco/foundation/aws//modules/vpc-scenario-2"
  cidr                 = local.cidr
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  azs                  = data.aws_availability_zones.azs.names
  name_prefix          = "test"
  region               = local.region
}

module "ubuntu" {
  source = "fpco/foundation/aws//modules/ami-ubuntu"
}

resource "aws_key_pair" "main" {
  public_key = file("./id_rsa.pub")
}

resource "aws_security_group" "ssh" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "tester" {
  source             = "../../modules/single-node-asg"
  name_prefix        = "ebs"
  name_suffix        = "test"
  key_name           = aws_key_pair.main.key_name
  ami                = module.ubuntu.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.ssh.id]
  region             = local.region
  data_volumes       = [{ name = "a", device = "/dev/xvdm", size = 50 }, { name = "b", device = "/dev/xvdn" }]
}
