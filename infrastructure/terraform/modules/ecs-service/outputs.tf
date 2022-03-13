#
# Outputs of this module
#
output "service_arn" {
  value = aws_ecs_service._.name
}
output "service_name" {
  value = aws_ecs_service._.name
}
output "task_arn" {
  value = aws_ecs_task_definition._.arn
}
output "task_family" {
  value = aws_ecs_task_definition._.family
}
