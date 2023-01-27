terraform {
  backend "s3" {
    bucket = "devsecops-poc"
    key    = "statefile/terraform.tfstate"
    region = "ap-south-1"
  }
}