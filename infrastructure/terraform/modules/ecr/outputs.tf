#
# Outputs of this module
#
output "repository_arn" {
  value = aws_ecr_repository._.arn
}
output "repository_url" {
  value = aws_ecr_repository._.repository_url
}
output "repository_name" {
  value = aws_ecr_repository._.name
}
