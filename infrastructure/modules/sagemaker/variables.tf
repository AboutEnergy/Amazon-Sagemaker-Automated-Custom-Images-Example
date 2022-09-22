variable "subnet_ids" {
  type        = list(any)
  description = "Subnet IDs to host SageMaker domain in"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to host SageMaker domain in"
}

variable "custom_docker_images" {
  type = map(object({
    kernel_name = string
  }))
  description = "Names of Docker images that will be created. Should be identical to directory names in custom_images dir."
}
