# AWS Sagemaker Studio Management

This repository can automatically provision a Sagemaker Studio domain and maintain custom docker images to be made available in the Studio UI.  

- [AWS Sagemaker Studio Management](#aws-sagemaker-studio-management)
  - [Repository Structure](#repository-structure)
  - [Getting Started](#getting-started)
    - [AWS Account Setup](#aws-account-setup)
      - [OpenID Connect (OIDC)](#openid-connect-oidc)
      - [Terraform Remote State Setup](#terraform-remote-state-setup)
        - [**Automatically provision via Terragrunt**](#automatically-provision-via-terragrunt)
        - [**Manually provision and update the backend.tf**](#manually-provision-and-update-the-backendtf)
      - [Get Deploying!](#get-deploying)
  - [SageMaker Studio](#sagemaker-studio)
  - [SageMaker Custom Images](#sagemaker-custom-images)
    - [Create New Subdirectory](#create-new-subdirectory)
    - [Add your Dockerfile](#add-your-dockerfile)
    - [Add the configuration to the infrastructure](#add-the-configuration-to-the-infrastructure)
    - [Create a PR and merge!](#create-a-pr-and-merge)
    - [Modifiying An Existing Custom Image](#modifiying-an-existing-custom-image)

## Repository Structure

- [`.devcontainer`](.devcontainer/): contains definition for development environment. Add additional dependencies or extensions here.
- [`.github`](.github): contains definitions for CI/CD workflows as well as PR template.
- [`custom_images](custom_images/): contains docker images to be built and attached to the Sagemaker domain.
- [`infrastructure`](infrastructure/): contains terraform code to define AWS resources onto which the application code will be deployed on.
- [`scripts`](scripts): contains bash scripts which are called by the Makefile to simplify chaining of commands.
- [local.env.example](local.env.example): contains template for environment variables that should be used for local development. 
- [Makefile](Makefile): where the magic happens. Contains targets that are used for automation.

## Getting Started

To get started using this repository there will be a few steps for setup that will need to be taken to attach the automation to your own AWS account.

### AWS Account Setup

#### OpenID Connect (OIDC)

To allow GitHub actions to access and manage resources in your AWS account, you will need to set up an OpenID Connection (OIDC). 
OIDC is a secure way of allowing the GitHub actions runner to temporarily assume a role in your AWS account without having to store access keys or secrets in GitHub.
The credentials will be provisioned on the fly and will be short-lived e.g. 1 hour. To do this please follow the steps in this [tutorial](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

#### Terraform Remote State Setup

Terraform uses remote state to centrally maintain the state file associated with a workspace ([Terraform Remote State Docs](https://www.terraform.io/language/state/remote)). To set this up an S3 bucket and DynamoDB table is required. In this repo we have provided two options as to how to set up this remote state.

##### **Automatically provision via Terragrunt**

The first option and default is to use [Terragrunt](https://terragrunt.gruntwork.io/), a thin wrapper around Terraform, to automatically provision the backend for you if the resources do not exist. To use this method, simply edit the values for the S3 bucket name, state file path and DynamoDB table name in the [infrastructure/terragrunt.hcl](infrastructure/terragrunt.hcl) file. The scripts have been set to use Terragrunt by default so this is all you need to do.

##### **Manually provision and update the backend.tf**

The second option is as the title says, to manually provision the S3 bucket and DynamoDB table via the console. You can follow [this tutorial](https://www.terraform.io/language/settings/backends/s3). After this the names, paths should be filled out in the [infrastructure/backend.tf](infrastructure/backend.tf) file.

#### Get Deploying!

Now you should have everything you need to start deploying so kick off the workflow associated with [.github/workflows/ci.yml](.github/workflows/ci.yml)!

## SageMaker Studio 

You can see the setup for the Sagemaker Studio Domain in [`infrastructure/modules/sagemaker/main.tf`](infrastructure/modules/sagemaker/main.tf). 
Currently, it has been configured to also add a lifecycle configuration script which automatically kills idle instances of the Jupyter session by default (this helps with saving on costs). This is provisioned in the following resource:

```hcl
# Lifecycle Configuration

resource "aws_sagemaker_studio_lifecycle_config" "auto_kill_idle_instance" {
  studio_lifecycle_config_name     = "auto-kill-idle"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = base64encode(file("${path.module}/scripts/auto_kill_idle_instance.sh"))
}
```

Feel free to modify this infrastructure code to best suit your needs.

## SageMaker Custom Images

This repository manages the Sagemaker domain and corresponding Studio app that is available to internal AE staff. To add a new custom image
please follow the instructions below:

### Create New Subdirectory

In the `custom_images` folder, please create a new directory whose name is the name of the final docker image e.g. pybamm-22-4. This name should only contain alphanumeric characters and hyphens.

### Add your Dockerfile

In the subdirectory created in the previous step, add your Dockerfile and supporting files. For an example, please look at [`custom_images/python-requirements`](custom_images/python-requirements/).

Then see if this builds by setting the `IMAGE_NAME` in your `local.env` file to be the same as this image and run `make docker_build`. Also follow
the instructions in these [local testing docs](https://github.com/aws-samples/sagemaker-studio-custom-image-samples/blob/main/DEVELOPMENT.md#local-testing) to get the kernel name. This will be important for the next step.

### Add the configuration to the infrastructure

To be able to push the images to a hosted Amazon ECR repository, please add the same `IMAGE_NAME` to [`infrastructure/custom_images.auto.tfvars`](infrastructure/custom_images.auto.tfvars) in the `sagemaker_custom_images` and add the corresponding kernel name found in the previous step in the form:

```hcl
"<IMAGE_NAME>" = {
    kernel_name = "<KERNEL_NAME>"
  }
```

Additionally, we need to ask the Github CI pipeline to build and integrate this image too. So in [`.github/workflows/ci.yml`](.github/workflows/ci.yml), please add to the `sagemaker` job matrix your image name. e.g:

```yml
# Add More tasks such as build, test, deploy applications e.g.
  sagemaker:
    name: Sagemaker Custom Images
    runs-on: ubuntu-latest
    needs: [infrastructure]
    strategy:
      matrix:
        image_name: [
            python-requirements,
            <IMAGE_NAME> # <- add image name to list
            ]
```

### Create a PR and merge!

After this you should be all set up to get your custom image deployed automatically. So open a PR and get it merged :).

### Modifiying An Existing Custom Image

If you wanted to modify an existing image, it is as easy as just changing the image definition in its subfolder. 
Once a PR is opened and merged, the CI pipeline will automatically propagate the new version to Sagemaker Studio! 
As an efficiency note, the CI workflow will only build and update an image if its files have changed saving you time and money.