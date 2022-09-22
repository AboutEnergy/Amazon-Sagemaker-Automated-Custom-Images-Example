# Locals
locals {
  deploy_image_tag = "latest"
}

# Utilites

data "aws_region" "current" {}

# Sagemaker Domain

resource "aws_sagemaker_domain" "this" {
  domain_name = "example"
  auth_mode   = "SSO"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = aws_iam_role.sagemaker_execution_role.arn

    kernel_gateway_app_settings {
      dynamic "custom_image" {
        for_each = aws_sagemaker_app_image_config.sagemaker_custom_images
        iterator = ci
        content {
          app_image_config_name = ci.value.app_image_config_name
          image_name            = aws_sagemaker_image_version.sagemaker_custom_images[ci.key].image_name
        }
      }

    }

    jupyter_server_app_settings {
      default_resource_spec {
        lifecycle_config_arn = aws_sagemaker_studio_lifecycle_config.auto_kill_idle_instance.arn
      }

      lifecycle_config_arns = [
        aws_sagemaker_studio_lifecycle_config.auto_kill_idle_instance.arn
      ]
    }
  }

  tags = {
    Application = "Battery Parameterisation"
  }

  lifecycle {
    # Ignore changes that would be automatically populated in Studio UI
    ignore_changes = [
      default_user_settings[0].sharing_settings,
      default_user_settings[0].jupyter_server_app_settings[0].default_resource_spec[0].instance_type,
      default_user_settings[0].jupyter_server_app_settings[0].default_resource_spec[0].sagemaker_image_arn
    ]
  }
}

resource "aws_iam_role" "sagemaker_execution_role" {
  name               = "sagemaker_execution_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_execution_role.json
}

data "aws_iam_policy_document" "sagemaker_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "sagemaker_execution_role" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"

}

# Sagemaker ECR repository

resource "aws_ecr_repository" "sagemaker_custom_images" {
  for_each             = var.custom_docker_images
  name                 = each.key
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Application = "SageMaker Custom Images"
  }
}

# Push initial image
resource "null_resource" "initial_image" {
  for_each = var.custom_docker_images

  triggers = {
    voltt_fe_ecr_repo_id = aws_ecr_repository.sagemaker_custom_images[each.key].registry_id
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/build_push_image.sh"
    interpreter = ["/bin/bash", "-c"]

    environment = {
      IMAGE_NAME = each.key
      ECR_REPO   = aws_ecr_repository.sagemaker_custom_images[each.key].repository_url
      IMAGE_TAG  = local.deploy_image_tag
      REGION     = data.aws_region.current.name
    }
  }

}

# Create Sagemaker images

resource "aws_sagemaker_image" "sagemaker_custom_images" {
  for_each   = var.custom_docker_images
  image_name = each.key
  role_arn   = aws_iam_role.sagemaker_execution_role.arn
}

resource "aws_sagemaker_image_version" "sagemaker_custom_images" {
  for_each   = aws_sagemaker_image.sagemaker_custom_images
  image_name = each.value.id
  base_image = "${aws_ecr_repository.sagemaker_custom_images[each.key].repository_url}:latest"

  depends_on = [
    null_resource.initial_image
  ]
}

resource "aws_sagemaker_app_image_config" "sagemaker_custom_images" {
  for_each              = var.custom_docker_images
  app_image_config_name = each.key

  depends_on = [
    aws_sagemaker_image.sagemaker_custom_images
  ]

  kernel_gateway_image_config {
    kernel_spec {
      name = each.value.kernel_name
    }

    file_system_config {}
  }
}

# Lifecycle Configuration

resource "aws_sagemaker_studio_lifecycle_config" "auto_kill_idle_instance" {
  studio_lifecycle_config_name     = "auto-kill-idle"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = base64encode(file("${path.module}/scripts/auto_kill_idle_instance.sh")) # Should be replaced by file64 when terraform is upgraded
}