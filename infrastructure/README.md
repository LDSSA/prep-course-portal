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
1. for first time deployment we need
    * docker installed on your local machine
    * region configures in your aws profile (ex: `aws configure set region eu-west-1`)~
    * configure a region in your ~/.aws/credentials file
    * boto3 installed in the current avtive virtual environment

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

# outputs

Outputs:

* aws_db_instance_arn = arn:aws:rds:eu-west-1:036806565123:db:terraform-20220319170353731200000002
* aws_db_instance_host = terraform-20220319170353731200000002.ctq2kxc7kx1i.eu-west-1.rds.amazonaws.com
* aws_default_region = eu-west-1
* aws_ecr_repository_arn = arn:aws:ecr:eu-west-1:036806565123:repository/prep-course-portal_production
* aws_ecr_repository_name = prep-course-portal_production
* aws_ecr_repository_url = 036806565123.dkr.ecr.eu-west-1.amazonaws.com/prep-course-portal_production
* aws_ecs_service_arn = prep-course-portal-production_service
* aws_ecs_service_name = prep-course-portal-production_service
* aws_ecs_task_definition_arn = arn:aws:ecs:eu-west-1:036806565123:task-definition/prep-course-portal-production_task:1
* aws_ecs_task_definition_family = prep-course-portal-production_task
* aws_lb_arn = arn:aws:elasticloadbalancing:eu-west-1:036806565123:loadbalancer/app/prep-course-portal-production/dc5143dbe4bff464
* aws_lb_dns_name = prep-course-portal-production-696130803.eu-west-1.elb.amazonaws.com
* aws_lb_name = prep-course-portal-production
* aws_route53_record_fqdn = prep-course-portal.ldsacademy.org
* aws_route53_record_name = prep-course-portal.ldsacademy.org
* cluster_name = ecs-cluster-prod
* docker_build_context = ../../prep-course-portal
* docker_tag = 1.0
* stage = production

# get shell in container

* install https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-debian
* 
