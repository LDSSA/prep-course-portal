# Continuous Deployment

## Description

This folder handles the continuous deployment of updated Docker images to our service. Nothing here should be run manually, and instead delegated to a CD pipeline (e.g. Gitlab).

## How it works

The scripts in this folder rely on the existence of the following environment variables:

* REPOSITORY_URL: the URL of the repository to store the new image (`aws_ecr_repository_url`)
* TASK_FAMILY: the ECS task family (`aws_ecs_task_definition_family`)
* SERVICE_NAME: the name of the ECS service (`aws_ecs_service_name`)
* AWS_DEFAULT_REGION: the region where the service is deployed (`aws_default_region`)
* STAGE: the environment stage (staging, production, etc.), used to identify the logs coming from each deployment. (`stage`)
* CLUSTER_NAME: the name of the ECS cluster (`cluster_name`)
* DOCKER_BUILD_CONTEXT: path of the folder containing the Dockerfile to build, relative to this folder (`docker_build_context`)
* The credentials of the `bt-tracking-server-cicd` AWS IAM user:
  * AWS_ACCESS_KEY_ID: an access key ID with permissions to interact with ECR/ECS (`aws_access_key_id`)
  * AWS_SECRET_ACCESS_KEY: the secret access key (`aws_secret_access_key`)
* DOCKER_TAG: the tag of the image being built (`docker_tag`)
* REPOSITORY_NAME: the local name of the image being built (only important if the local image is used for anything else other than being tagged and pushed) (`aws_ecr_repository_name`)

whose values can be obtained from the output of `terraform apply`, when the service was first created.

Check the `.gitlab-ci.yml` for an example of how to set these variables.

**WARNING:** There is no health check and automatic rollback of the server, which means that if a Dockerfile with an error is uploaded, the ECS service will be stuck on a loop trying to create the tasks and shutting them down. Always verify if a deployment was successful after pushing, and if not, manually revert to the previous revision of the task definition using the ECS interface.
