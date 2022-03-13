#
# This module defines the ECR, the repo for the container images that will run
# in ECS.
#

// ECR
resource "aws_ecr_repository" "_" {
  # the name of ECR repository that will be created to store the server's
  # Docker image (`stage` is appended to the name, so you can leave the same
  # repository name for all your stages).
  name                 = "${var.app_name}_${var.stage}"
  image_tag_mutability = "IMMUTABLE"
}

// Building and pushing image
resource "null_resource" "build_and_push" {
  provisioner "local-exec" {
    working_dir = "../deployment" # relative to where terraform apply is run, which is the terraform folder
    command     = "./build_and_push.sh"
    environment = {
      DOCKER_BUILD_CONTEXT = var.docker_build_context
      DOCKER_TAG           = var.docker_tag
      REPOSITORY_NAME      = aws_ecr_repository._.name
      REPOSITORY_URL       = aws_ecr_repository._.repository_url
    }
  }

  depends_on = [aws_ecr_repository._]
}