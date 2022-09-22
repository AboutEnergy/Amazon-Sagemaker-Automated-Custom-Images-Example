#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

# Extracted from infrastructure outputs
. "$SCRIPT_DIR/../.env"

# DIR is env var set to folder name in docker directory where Dockerfile lives
cd "$SCRIPT_DIR/../custom_images/$IMAGE_NAME"

aws --region ${REGION} sagemaker create-image-version \
    --image-name ${IMAGE_NAME} \
    --base-image "${ECR_REPO}:${IMAGE_TAG}"

