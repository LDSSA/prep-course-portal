#
# Defines the output outputs for a deployment.
#

# Outputs from terraform/variables.tf
output "aws_default_region" {
  value = var.region
}
output "stage" {
  value = var.stage
}
output "cluster_name" {
  value = var.cluster_name
}
output "docker_build_context" {
  value = var.docker_build_context
}
output "docker_tag" {
  value = var.docker_tag
}

# Outputs from terraform/modules/ecr/outputs.tf
output "aws_ecr_repository_arn" {
  value = module.ecr.repository_arn
}
output "aws_ecr_repository_url" {
  value = module.ecr.repository_url
}
output "aws_ecr_repository_name" {
  value = module.ecr.repository_name
}

# Outputs from terraform/modules/ecs/outputs.tf
output "aws_ecs_service_arn" {
  value = module.ecs-service.service_arn
}
output "aws_ecs_service_name" {
  value = module.ecs-service.service_name
}
output "aws_ecs_task_definition_arn" {
  value = module.ecs-service.task_arn
}
output "aws_ecs_task_definition_family" {
  value = module.ecs-service.task_family
}

# Outputs from terraform/modules/load-balancer/outputs.tf
output "aws_lb_arn" {
  value = module.load-balancer.arn
}
output "aws_lb_name" {
  value = module.load-balancer.name
}
output "aws_lb_dns_name" {
  value = module.load-balancer.dns_name
}

# Outputs from terraform/modules/postgres-rds/outputs.tf
output "aws_db_instance_arn" {
  value = module.postgres-rds.arn
}
output "aws_db_instance_host" {
  value = module.postgres-rds.db_host
}

# Outputs from terraform/modules/route-53/outputs.tf
output "aws_route53_record_name" {
  value = module.route-53.record_name
}
output "aws_route53_record_fqdn" {
  value = module.route-53.record_fqdn
}
