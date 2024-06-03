terraform {
  backend "s3" {
    bucket         = "danit-devops-tf-state"
    key            = "illia/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "illia-tf-step"
  }
}

