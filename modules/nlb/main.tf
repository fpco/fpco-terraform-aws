resource "aws_lb" "nlb" {
  name               = "${var.name_prefix}-nlb"
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_listener" "lb-listener" {
  count             = length(var.ports)
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.ports[count.index][0]
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg[count.index].arn
  }
}

resource "aws_lb_target_group" "lb-tg" {
  count    = length(var.ports)
  name     = "${var.name_prefix}-tg-${count.index}"
  port     = var.ports[count.index][1]
  protocol = "TCP"
  vpc_id   = var.vpc_id
  tags     = var.tags
}
