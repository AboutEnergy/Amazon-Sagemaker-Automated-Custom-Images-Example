# Current account

data "aws_caller_identity" "current" {}

# Networking

resource "aws_default_vpc" "vpc" {
  tags = {
    Name        = "Default VPC"
    Application = "Networking"
  }
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.vpc.id]
  }
}

# Sagemaker Domain

module "sagemaker" {
  source = "./modules/sagemaker"

  vpc_id     = aws_default_vpc.vpc.id
  subnet_ids = data.aws_subnets.default_subnets.ids

  custom_docker_images = var.sagemaker_custom_images
}