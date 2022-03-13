import boto3
import argparse


def create_new_task_definition_revision(
    family: str,
    image_url: str
):
    """Creates a new revision for a task definition of a given family that is
    identical to the latest one, but points to a new docker image.
    """

    # Connecting to ECS
    client = boto3.client('ecs')

    # Fetching all task definitions ARNs for the family, in descending order
    task_definition_arns = client.list_task_definitions(
        familyPrefix=family,
        sort='DESC'
    )

    # Fetching the latest task definition
    task_definition = client.describe_task_definition(
        taskDefinition=task_definition_arns['taskDefinitionArns'][0]
    )
    task_definition = task_definition["taskDefinition"]

    # Extracting the desired keys and updating the image
    task_definition["containerDefinitions"][0]["image"] = image_url

    # Registering the new task definition
    new_task_def = client.register_task_definition(
        family=task_definition["family"],
        taskRoleArn=task_definition["taskRoleArn"],
        executionRoleArn=task_definition["executionRoleArn"],
        networkMode=task_definition["networkMode"],
        containerDefinitions=task_definition["containerDefinitions"],
        volumes=task_definition["volumes"],
        placementConstraints=task_definition["placementConstraints"],
        requiresCompatibilities=task_definition["requiresCompatibilities"],
        cpu=task_definition["cpu"],
        memory=task_definition["memory"]
    )

    new_task_def_arn = new_task_def["taskDefinition"]["taskDefinitionArn"]
    previous_task_def_arn = task_definition["taskDefinitionArn"]

    return new_task_def_arn, previous_task_def_arn


def update_service(
    cluster_name: str,
    service_name: str,
    task_definition_arn: str
):
    """Updates the ECS service to use a new revision of the task definition.
    """
    # Connecting to ECS
    client = boto3.client('ecs')

    # Updating the service to point to the new task definition revision.
    response = client.update_service(
        cluster=cluster_name,
        service=service_name,
        taskDefinition=task_definition_arn
    )

    return response


def main(
    cluster_name: str,
    service_name: str,
    family: str,
    image_url: str
):
    """Creates a new revision of the task definition, and updates the service.
    """

    new_task_def_arn, prev_task_def_arn = create_new_task_definition_revision(
        family=family,
        image_url=image_url
    )

    response = update_service(
        cluster_name=cluster_name,
        service_name=service_name,
        task_definition_arn=new_task_def_arn
    )

    return response


def _configure_argparser():
    """Configures the argument parser.
    """

    parser = argparse.ArgumentParser(description='Deploy a new revision.')

    parser.add_argument(
        '--cluster-name',
        help="The ECS cluster name."
    )
    parser.add_argument(
        '--service-name',
        help="The name of the ECS service."
    )
    parser.add_argument(
        '--family',
        help="The task family."
    )
    parser.add_argument(
        '--image-url',
        help="The URL of the image for the new revision."
    )

    return parser


if __name__ == "__main__":

    parser = _configure_argparser()

    args = parser.parse_args()

    response = main(
        cluster_name=args.cluster_name,
        service_name=args.service_name,
        family=args.family,
        image_url=args.image_url
    )

    print(response)
