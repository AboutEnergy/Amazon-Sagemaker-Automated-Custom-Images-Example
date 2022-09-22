#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

# default value
ECR_REPO=$IMAGE_NAME

if [[ -f "$SCRIPT_DIR/../.env" ]]; then
    # Generated from infrastructure outputs
    . "$SCRIPT_DIR/../.env"
fi

# DIR is env var set to folder name in docker directory where Dockerfile lives
cd "$SCRIPT_DIR/../custom_images/$IMAGE_NAME"

# ECR_REPO is of the form ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${IMAGE_NAME}

# Docker login
# If outputs are present
if [[ -f "$SCRIPT_DIR/../.env" ]]; then
    # Frontend variables
    # Docker login
    aws ecr get-login-password --region $REGION | \
    docker login --username AWS --password-stdin "$ECR_REPO:$IMAGE_TAG"

    docker pull "$ECR_REPO:$IMAGE_TAG"
fi


# Build docker image
docker build $BUILD_ARGS --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from $ECR_REPO \
    -t "$ECR_REPO:$IMAGE_TAG" .



