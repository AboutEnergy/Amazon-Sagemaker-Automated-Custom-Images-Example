# Add inputs for all infrastructure here.
# They can also be added through env vars when prefixed with TF_VAR e.g. TF_VAR_example="hi"

variable "sagemaker_custom_images" {
  type = map(object({
    kernel_name = string
  }))
  description = "Names of Docker images that will be created. Should be identical to directory names in ./custom_images/ dir."
}