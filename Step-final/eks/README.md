### Terraform init
```sh
terraform init -backend-config "region=eu-central-1" -backend-config "profile=mfa"
```

### Terraform apply
```sh
terraform apply -var="iam_profile=mfa"
```
