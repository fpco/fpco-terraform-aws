provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source              = "fpco/foundation/aws//modules/vpc-scenario-1"
  cidr                = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  region              = "us-west-2"
  azs                 = data.aws_availability_zones.azs.names
  name_prefix         = "nlb-poc"
}

module "ubuntu" {
  source  = "fpco/foundation/aws//modules/ami-ubuntu"
  release = "18.04"
}

module "asg" {
  source                = "fpco/foundation/aws//modules/asg"
  azs                   = []
  key_name              = "shida-west-2"
  subnet_ids            = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[2]]
  name_prefix           = "nlb-poc"
  min_nodes             = 2
  ami                   = module.ubuntu.id
  max_nodes             = 2
  security_group_ids    = [aws_security_group.sg-asg.id]
  alb_target_group_arns = module.nlb.target_group_arns
  user_data             = <<EOF
#!/bin/bash -
apt update
apt install python3
wget -O hostname.py https://gist.githubusercontent.com/Magicloud/120357225843eeebcb70205a79f61999/raw/91ac3f205aa4812834f08dd82ea639dd0b5d1cfc/hostname.py
chmod a+x hostname.py
./hostname.py &
EOF
}

resource "aws_security_group" "sg-asg" {
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10000
    to_port     = 10000
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

module "nlb" {
  name_prefix = "nlb-poc"
  source      = "../../modules/nlb"
  internal    = false
  subnet_ids  = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[2]]
  ports       = [[10000, 10000]]
  vpc_id      = module.vpc.vpc_id
}

output "lb" {
  value = module.nlb.lb_dns_name
}
