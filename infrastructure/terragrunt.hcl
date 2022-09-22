# Set up remote backend to point to corresponding s3 bucket in the account you are deploying to.
# Replace bucket and dynamodb table names with those corresponding to your AWS account.
# If resources do not exist, Terragrunt will automatically provision them.

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "my-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}