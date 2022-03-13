#
# Defines the variables for a deployment. By default all variables are strings
# unless otherwise specified.
#

# Variables from `deploy.sh`
variable "app_name" {}
variable "stage" {}
variable "region" {}
variable "aws_profile" {}

# Variables from `<stage>.tfvars`
variable "docker_build_context" {}
variable "docker_tag" {}
variable "route53_zone_id" {}
variable "route53_zone_domain_name" {}
variable "record_name" {}
variable "https_certificate_arn" {}
variable "db_name" {}
variable "rds_instance_type" {}
variable "db_user" {}
variable "db_password" {}
variable "cluster_id" {}
variable "cluster_name" {}
variable "container_port" {
  type = number
}
variable "task_cpu" {}
variable "task_memory" {}
variable "service_desired_count" {}
variable "service_health_check_grace_period_seconds" {}
variable "server_target_group_deregistration_delay" {}
variable "django_secret_key" {}
variable "vpc_id" {}
variable "vpc_subnets" {
  type = list(string)
}
variable "vpc_cidr_block" {}
