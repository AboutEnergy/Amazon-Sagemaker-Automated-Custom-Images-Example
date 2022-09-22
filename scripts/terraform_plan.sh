#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo "AWS_PROFILE = $AWS_PROFILE"
fi

cd "$SCRIPT_DIR/../infrastructure"

terragrunt plan -out=tfplan
terragrunt show -no-color tfplan > tfplan.txt