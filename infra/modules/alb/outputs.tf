output "alb_dns_name" {
  value = aws_lb.ipark_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.ipark_tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.ipark_listener.arn
}