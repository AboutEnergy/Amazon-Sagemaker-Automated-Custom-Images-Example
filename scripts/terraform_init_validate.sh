#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

cd "$SCRIPT_DIR/../infrastructure"

tflint --init
terragrunt init -reconfigure
tflint --module
