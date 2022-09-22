#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Change to root
cd "$SCRIPT_DIR/../../../../custom_images/$IMAGE_NAME" 

# Docker login
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin "$ECR_REPO:$IMAGE_TAG"

# Build docker image
docker build --build-arg BUILDKIT_INLINE_CACHE=1 \
    -t "$ECR_REPO:$IMAGE_TAG" .

# Push docker image
docker push "$ECR_REPO:$IMAGE_TAG"