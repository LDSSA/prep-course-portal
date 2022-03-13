#
# Defines the variables for this module. By default all variables are strings
# unless otherwise specified.
#

# Variables from terraform/variables.tf
variable "app_name" {}
variable "stage" {}
variable "https_certificate_arn" {}
variable "vpc_subnets" {
  type = list(string)
}
variable "vpc_id" {}
