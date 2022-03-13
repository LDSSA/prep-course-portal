#
# Defines the variables for this module. By default all variables are strings
# unless otherwise specified.
#

# Variables from terraform/variables.tf
variable "route53_zone_id" {}
variable "route53_zone_domain_name" {}
variable "record_name" {}

# Variables from terraform/modules/load-balancer/outputs.tf
variable "lb_dns_name" {}
variable "lb_zone_id" {}
