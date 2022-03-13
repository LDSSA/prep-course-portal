#!/bin/bash

#--------------------------------------------------------------
# Script used to deploy the infrastructure.
#
# Here we should ask for user input on variables that:
# * depend on the development environment of the person who is doing the
#   deployment
# * are used it in the `terraform init` command
#--------------------------------------------------------------

APP_NAME="prep-course-portal"
STAGE="production"
# The aws profile that you want to use for this deployment
# (choose from ~/.aws/credentials).
#read AWS_PROFILE
AWS_PROFILE="ldsa"

echo "
Deploying app: ${APP_NAME}
Stage: ${STAGE}"
# the application name (for tag information)
# Name of the manually created s3 bucket that will contain the terraform state
# of this app.
TFSTATE_BUCKET_NAME="ldsa-infrastructure-tf-states"
# Your AWS account region.
# We have the region here because we use it in the `terraform init`, otherwise
# we would just have this in the <stage>.tfvars file.
REGION="eu-west-1"

# the key defines the path to the `.tfstate` file inside the s3 bucket
# credentials are set here but there's probably a better way to do this
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile $AWS_PROFILE) \
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile $AWS_PROFILE) \
aws_profile=$AWS_PROFILE terraform init \
    -backend-config="region=${REGION}" \
    -backend-config="bucket=${TFSTATE_BUCKET_NAME}" \
    -backend-config="key=${APP_NAME}-${STAGE}/terraform.tfstate"

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile $AWS_PROFILE) \
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile $AWS_PROFILE) \
terraform apply \
    -var app_name=$APP_NAME -var stage=$STAGE \
    -var region=$REGION -var aws_profile=$AWS_PROFILE \
    -var-file="${STAGE}.tfvars"
