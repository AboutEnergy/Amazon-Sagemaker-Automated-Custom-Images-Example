#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

# default value
ECR_REPO=$IMAGE_NAME

# Generated from infrastructure outputs
. "$SCRIPT_DIR/../.env"

# DIR is env var set to folder name in docker directory where Dockerfile lives
cd "$SCRIPT_DIR/../custom_images/$IMAGE_NAME"

aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin "$ECR_REPO:$IMAGE_TAG"

# Push docker image
docker push $ECR_REPO:$IMAGE_TAG 



