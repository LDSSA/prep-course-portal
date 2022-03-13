#
# This module defines the route 53 record that resolves to the
# load balencer's DNS name.
#

# Using an alias A record because:
#   Route 53 doesn't charge for alias queries to AWS resources (whereas they
#   they do charge for CNAME record queries)
# https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html
resource "aws_route53_record" "_" {
  zone_id = var.route53_zone_id
  name    = "${var.record_name}.${var.route53_zone_domain_name}"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}
