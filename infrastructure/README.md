# Deployment

## ECS Pre-Deployment Instructions

## How to deploy this infrastructure:

The deployment is done using the `deploy.sh` script located at the infrastructure folder.
There is a set manual steps that you need to do before you run the script, and also a set of manual steps to do after running the script.

1. alocate a domain name for the project on route53
1. install terraform or check that it is installed
    * <https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform>
1. install aws cli or check that it is installed
    * <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html>
    * configure aws cli
        * <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html>
1. manually create the s3 bucket that will contain the terraform state os the infrastructure in this project
    * created one called "ldsa-infrastructure"

Now run `deploy_<stage>.sh`

Manual steps to do after the script:

1. Create a record on freenom with the name we chose in the `<stage>.tfvars` file and wait 30 min for it to take effect
1. after the record has taken effect, you must ssh into the ec2 machine with a root shell and run certbot by going to the nginx configuratin file and running the last line titled `# Run certbot`

## Credentials and secrets

* credentials and secrets are managed on <vault.bitwarden.com>


## ECS Deployment Instructions

To deploy the ECS service, first create an HTTPS certificate on AWS Certificate Manager: <https://aws.amazon.com/certificate-manager/>
This allows sending encrypted traffic to the load balancer, which will then route it to the server.
Follow these steps:

* Request Certificate
* Request a Public Certificate
* Add your domain name, and press "Next"
* Choose DNS validation
* Press "Review" and then "Confirm and Request"
* Follow the instructions to create a CNAME In your DNS configuration, so that the certificate can be issued
* When the process is concluded, take note of the ARN of your certificate (under "Details")

After obtaining the certificate, go to the terraform folder and fill the `<stage>.tfvars` with the appropriate values for the `<stage>` you are deploying (staging or production).

To deploy the infrastructure, first check that the `deploy_<stage>.sh` script has the correct values in the variables, then run `source deploy_<stage>.sh` and follow the steps.

The output of `terraform apply` has a lot of information which you should take note of. Keep in mind that to run the Terraforms for the first time, you'll need to configure your AWS credentials, since an image needs to be pushed to ECR.

The remaining outputs should be passed to your CI/CD pipeline, to automate the creation and deployment of new revisions of the server task definition (see `deployment` folder for more details).

After deploying the service, make sure to create an aws secret with the content of the `<stage>.tfvars` file, so that this file is accessible to other members of the organization.

## ECS Redeployment Instructions

In case we need to update the environment variables inside the containers, we need to destroy the task definition and the service, and then apply those same components, like so:

```bash
terraform destroy \
    -var app_name=$APP_NAME -var stage=$STAGE \
    -var region=$REGION -var aws_profile=$AWS_PROFILE \
    -var-file="${STAGE}.tfvars" \
    -target module.ecs-service.aws_ecs_task_definition._ \
    -target module.ecs-service.aws_ecs_service._

terraform apply \
    -var app_name=$APP_NAME -var stage=$STAGE \
    -var region=$REGION -var aws_profile=$AWS_PROFILE \
    -var-file="${STAGE}.tfvars" \
    -target module.ecs-service.aws_ecs_task_definition._ \
    -target module.ecs-service.aws_ecs_service._
```
