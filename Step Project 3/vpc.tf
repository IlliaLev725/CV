module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = var.public_subnet
  private_subnets = var.private_subnet
  enable_nat_gateway = true

  tags = {
    Name = "Illia"
    Terraform = "true"
    Environment = "dev"
  }
}
