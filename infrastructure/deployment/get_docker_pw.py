import boto3
import base64


def main():
    """Gets the ECR password for the currently configured AWS user.
    """

    client = boto3.client('ecr')
    data = client.get_authorization_token()
    token = data['authorizationData'][0]['authorizationToken']
    token = base64.b64decode(token).decode('utf-8')
    username, password = token.split(":")
    password = ''.join(password)

    print(password)


if __name__ == '__main__':
    main()
