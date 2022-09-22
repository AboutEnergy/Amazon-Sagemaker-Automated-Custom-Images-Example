SHELL := /bin/bash

# Utils

aws_config_check:
	aws configure list

deploy: infra_init_validate infra_plan infra_apply

format:
	terraform fmt -recursive .

clean: 
	./scripts/terraform_clean.sh

# Infrastructure

infra_validate:
	tflint --module

infra_init_validate:
	./scripts/terraform_init_validate.sh

infra_plan:
	./scripts/terraform_plan.sh

infra_apply:
	./scripts/terraform_apply.sh

infra_destroy:
	./scripts/terraform_destroy.sh

extract_env_vars:
	python3 ./scripts/extract_infrastructure_vars.py -si $(IMAGE_NAME)

# Build

docker_build:
	./scripts/ci_docker_build_image.sh

docker_push:
	./scripts/ci_docker_push.sh

docker_test_python_dependencies:
	./scripts/ci_docker_test_image.sh

sagemaker_create_image_version:
	./scripts/sagemaker_create_image_version.sh


