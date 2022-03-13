#
# Defines the variables for this module. By default all variables are strings
# unless otherwise specified.
#

# Variables from terraform/variables.tf
variable "app_name" {}
variable "stage" {}
variable "container_port" {
  type = number
}
variable "docker_tag" {}
variable "region" {}
variable "task_cpu" {}
variable "task_memory" {}
variable "service_desired_count" {}
variable "service_health_check_grace_period_seconds" {}
variable "server_target_group_deregistration_delay" {}
variable "cluster_id" {}
variable "cluster_name" {}
variable "django_secret_key" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "vpc_subnets" {
  type = list(string)
}

# Variables from terraform/modules/ecr/outputs.tf
variable "repository_url" {}

# Variables from terraform/modules/load-balancer/outputs.tf
variable "lb_dns" {}
variable "lb_security_group_id" {}
variable "lb_http_listener_arn" {}
variable "lb_https_listener_arn" {}

# Variables from terraform/modules/postgres-rds/outputs.tf
variable "db_host" {}
variable "db_port" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
