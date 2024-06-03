# AWS account config
region = "eu-central-1"

# General for all infrastructure
# This is the name prefix for all infra components
name = "illia-step"


vpc_id      = "vpc-06ae62935ffb33e2b"
subnets_ids = ["subnet-0b27929ad2896d99f", "subnet-0c15a8c6856de7853", "subnet-01a5c422124b1c69e"]

tags = {
  Environment = "test"
  TfControl   = "true"
}

zone_name = "watashinoheyadesu.pp.ua"
