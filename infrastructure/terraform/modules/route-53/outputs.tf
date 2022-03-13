#
# Outputs of this module
#
output "record_name" {
  value = aws_route53_record._.name
}
output "record_fqdn" {
  value = aws_route53_record._.fqdn
}
