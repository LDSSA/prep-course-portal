#
# This is the main terraform file where the modules are declared.
#

provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

terraform {
  required_version = "~>0.12"
  backend "s3" {}
}

// ----- route-53 ----------
module "route-53" {
  source = "./modules/route-53"

  # Variables
  route53_zone_id          = var.route53_zone_id
  route53_zone_domain_name = var.route53_zone_domain_name
  record_name              = var.record_name

  # From other modules
  lb_dns_name = module.load-balancer.dns_name
  lb_zone_id  = module.load-balancer.zone_id
}
// ------------------------------


// ----- Load Balancer ----------
module "load-balancer" {
  source = "./modules/load-balancer"

  # Variables
  app_name = var.app_name
  stage    = var.stage

  # From existing infrastructure
  https_certificate_arn = var.https_certificate_arn
  vpc_id                = var.vpc_id
  vpc_subnets           = var.vpc_subnets
}
// ------------------------------


// ----- Postgres RDS ----------
module "postgres-rds" {
  source = "./modules/postgres-rds"

  # Variables
  app_name      = var.app_name
  stage         = var.stage
  db_name       = var.db_name
  instance_type = var.rds_instance_type
  db_user       = var.db_user
  db_password   = var.db_password

  # From existing infrastructure
  vpc_id         = var.vpc_id
  vpc_subnets    = var.vpc_subnets
  vpc_cidr_block = var.vpc_cidr_block
}
// ------------------------------


// ----- ECR - Elastic Container Registry ----------
module "ecr" {
  source = "./modules/ecr"

  # Variables
  app_name             = var.app_name
  stage                = var.stage
  docker_build_context = var.docker_build_context
  docker_tag           = var.docker_tag
}
// --------------------

// ----- ECS - Elastic Container Service----------
module "ecs-service" {
  source = "./modules/ecs-service"

  # Variables
  app_name                                  = var.app_name
  stage                                     = var.stage
  container_port                            = var.container_port
  docker_tag                                = var.docker_tag
  region                                    = var.region
  task_cpu                                  = var.task_cpu
  task_memory                               = var.task_memory
  service_desired_count                     = var.service_desired_count
  service_health_check_grace_period_seconds = var.service_health_check_grace_period_seconds
  server_target_group_deregistration_delay  = var.server_target_group_deregistration_delay
  django_secret_key                         = var.django_secret_key

  # From other modules
  repository_url        = module.ecr.repository_url
  lb_dns                = module.load-balancer.dns_name
  lb_security_group_id  = module.load-balancer.security_group_id
  lb_http_listener_arn  = module.load-balancer.http_listener_arn
  lb_https_listener_arn = module.load-balancer.https_listener_arn
  db_host               = module.postgres-rds.db_host
  db_port               = module.postgres-rds.db_port
  db_name               = module.postgres-rds.db_name
  db_username           = module.postgres-rds.db_username
  db_password           = module.postgres-rds.db_password

  # From existing infrastructure
  vpc_id         = var.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  vpc_subnets    = var.vpc_subnets
  cluster_id     = var.cluster_id
  cluster_name   = var.cluster_name
}
