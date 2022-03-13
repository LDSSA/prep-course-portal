#
# Defines the variables for this module. By default all variables are strings
# unless otherwise specified.
#

# Variables from terraform/variables.tf
variable "app_name" {}
variable "stage" {}
variable "db_name" {}
variable "instance_type" {}
variable "db_user" {}
variable "db_password" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "vpc_subnets" {
  type = list(string)
}
