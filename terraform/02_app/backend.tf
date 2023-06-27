terraform {
  backend "s3" {
    bucket               = "rachaelwilliams-terraform"
    workspace_key_prefix = "02_app"
    key                  = "terraform.tfstate"
    region               = "us-east-1"
  }
}