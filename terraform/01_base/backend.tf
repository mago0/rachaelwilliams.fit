terraform {
  backend "s3" {
    bucket = "rachaelwilliams-terraform"
    key    = "01_base/terraform.tfstate"
    region = "us-east-1"
  }
}