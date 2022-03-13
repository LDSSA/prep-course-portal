set -e

echo "Getting the Docker login password using boto"
docker_pw=$(python3 get_docker_pw.py)

echo "Building image in $DOCKER_BUILD_CONTEXT"
git clone $APP_REPOSITORY_URL # should be the url to the app repo, maybe of a specific branch
cd $DOCKER_BUILD_CONTEXT # should be the folder containing the Dockerfile

docker login --username AWS --password $docker_pw $REPOSITORY_URL

echo "Building $REPOSITORY_NAME"
docker build -t $REPOSITORY_NAME:$DOCKER_TAG .

echo "Tagging as $DOCKER_TAG"
docker tag $REPOSITORY_NAME:$DOCKER_TAG $REPOSITORY_URL:$DOCKER_TAG

echo "Pushing to $REPOSITORY_URL:$DOCKER_TAG"
docker push $REPOSITORY_URL:$DOCKER_TAG
