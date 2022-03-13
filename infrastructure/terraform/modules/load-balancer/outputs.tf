#
# Outputs of this module
#
output "arn" {
  value = aws_lb._.arn
}
output "name" {
  value = aws_lb._.name
}
output "dns_name" {
  value = aws_lb._.dns_name
}
output "zone_id" {
  value = aws_lb._.zone_id
}
output "security_group_id" {
  value = aws_security_group._.id
}
output "http_listener_arn" {
  value = aws_lb_listener.http.arn
}
output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}
