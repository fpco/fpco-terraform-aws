resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = var.lb_arn
  port              = var.lb_port
  protocol          = var.protocol
  ssl_policy        = var.protocol == "HTTP" ? "" : var.ssl_policy
  certificate_arn   = var.https_cert_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }
}

resource "aws_lb_target_group" "lb-tg" {
  port     = var.service_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = var.tags
}
