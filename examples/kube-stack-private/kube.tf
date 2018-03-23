module "kube-controller-iam" {
  source = "../../modules/kube-controller-iam"

  name_prefix = "${var.name}"
}

module "kube-worker-iam" {
  source = "../../modules/kube-worker-iam"

  name_prefix = "${var.name}"
}

module "kube-cluster" {
  source                 = "../../modules/kube-stack"
  availability_zones     = ["${slice(data.aws_availability_zones.available.names, 0, 2)}"]
  name_prefix            = "${var.name}"
  key_name               = "${aws_key_pair.main.key_name}"
  private_load_balancer  = false
  lb_subnet_ids          = ["${module.vpc.public_subnet_ids}"]
  worker_iam_profile     = "${module.kube-worker-iam.aws_iam_instance_profile_name}"
  controller_iam_profile = "${module.kube-controller-iam.aws_iam_instance_profile_name}"

  lb_security_group_ids = [
    "${module.kube-load-balancer-sg.id}",
  ]

  controller_ami        = "${var.coreos_stable_ami_id}"
  controller_subnet_ids = ["${module.vpc.private_subnet_ids}"]
  worker_ami            = "${var.coreos_stable_ami_id}"
  worker_subnet_ids     = ["${module.vpc.private_subnet_ids}"]

  controller_security_group_ids = [
    "${module.kube-controller-sg.id}",
  ]

  worker_security_group_ids = [
    "${module.kube-worker-sg.id}",
  ]
}

module "kube-controller-sg" {
  source      = "../../modules/kube-controller-sg"
  name        = "${var.name}-kube-controller"
  cidr_blocks = "${var.vpc_cidr}"
}

module "kube-worker-sg" {
  source      = "../../modules/kube-worker-sg"
  name        = "${var.name}-kube-worker"
  cidr_blocks = "${var.vpc_cidr}"
}

module "kube-loadbalancer-sg" {
  source      = "../../modules/kube-loadbalancer-sg"
  name        = "${var.name}-kube-loadbalancer"
  cidr_blocks = "${var.vpc_cidr}"
}
