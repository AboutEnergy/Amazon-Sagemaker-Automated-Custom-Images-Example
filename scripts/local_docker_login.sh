#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

# Generated from infrastructure outputs
. "$SCRIPT_DIR/../.env"

aws --region ${SAGEMAKER_DOMAIN_REGION} ecr get-login-password | \
docker login --username AWS --password-stdin ${ECR_REPO}
