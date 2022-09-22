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

docker run --rm -d --name ci_test $ECR_REPO pip list 

# docker kill ci_test 
docker logs -f ci_test 