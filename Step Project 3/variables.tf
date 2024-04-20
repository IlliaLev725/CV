variable "name" {
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnet" {
  type = list(string)
  default = ["10.0.1.0/24"]
}


variable "is_public" {
  default = true
}

variable "ingress_ports" {
  description = "List of ports to allow incoming traffic"
  type        = list(number)
  default     = [80, 22, 8080, 9090, 433, 9100, 9101, 9093, 3000]
}

variable "user_data" {
  default = ""
}

locals {
  userdata = var.user_data != "" ? var.user_data : templatefile("/home/illia/StepProject/config.yaml.tpl",
    {
      ssh_listen_port = 22
      hostname        = var.name

    }
  )
}

variable "zone_id" {}

variable "alb_domain" {}
