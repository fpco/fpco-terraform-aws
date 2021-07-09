output "lb_dns_name" {
  value = aws_lb.nlb.dns_name
}

output "target_group_arns" {
  value = aws_lb_target_group.lb-tg.*.arn
}
