# NOTE: fill this in if you do not want to use Terragrunt, make sure to replace the Terragrunt calls with 
# terraform calls in the scripts/terraform_*.sh files.

# Set up remote backend to point to corresponding s3 bucket in the account you are deploying to.
# Replace bucket and dynamodb table names with those corresponding to your AWS account.

terraform {
  backend "s3" {
    bucket         = "tf-state"
    key            = "state/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }
}