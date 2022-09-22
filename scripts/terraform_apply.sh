#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$CI" != "true" ]; then
    . "$SCRIPT_DIR/../local.env"
    echo $AWS_PROFILE
fi

cd "$SCRIPT_DIR/../infrastructure"

TFPLAN_FILE="tfplan"

if [[ -f "$TFPLAN_FILE" ]]; then
    echo "$TFPLAN_FILE exists."
    terraform apply "$TFPLAN_FILE"
fi

terragrunt output -json > out.json