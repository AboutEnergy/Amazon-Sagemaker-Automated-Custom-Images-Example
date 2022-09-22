output "sagemaker" {
  value       = module.sagemaker
  description = "Sagemaker Outputs"
}

output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "Account id of caller"
}