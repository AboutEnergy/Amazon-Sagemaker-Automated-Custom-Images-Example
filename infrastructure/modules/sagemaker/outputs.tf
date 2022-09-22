output "domain_id" {
  value       = aws_sagemaker_domain.this.id
  description = "Sagemaker Domain ID"
}

output "execution_role_arn" {
  value       = aws_iam_role.sagemaker_execution_role.arn
  description = "Sagemaker execution role arn"
}

output "custom_image_ecr_repository_urls" {
  value       = { for ecr_repo in aws_ecr_repository.sagemaker_custom_images : ecr_repo.name => ecr_repo.repository_url }
  description = "Sagemaker custom image ECR repo url"
}

output "domain_region" {
  value       = data.aws_region.current.name
  description = "Sagemaker custom image ECR repo url"
}

output "deploy_image_tag" {
  value       = local.deploy_image_tag
  description = "Docker Image tag which when pushed to will "
}