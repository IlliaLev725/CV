data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}



module "ec2_instance" {
  count = 3
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.name}-step3-${count.index + 1}"
  ami                    = data.aws_ami.ubuntu.id
  associate_public_ip_address = var.is_public
  instance_type          = "t2.micro"
  user_data              = local.userdata
  key_name               = aws_key_pair.ssh.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.securitygroup.id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
output "ec2_public" {
  value = module.ec2_instance[*].public_ip
}

resource "local_file" "ansible_inventory" {
  depends_on = [module.ec2_instance]

  content = <<-EOT
  all:
    children:
      observer:
        hosts:
          padok-observer:
            ansible_host: ${module.ec2_instance[0].public_ip}
            ansible_ssh_private_key_file: ~/.ssh/id_rsa
            ansible_user: illia
      target:
        hosts:
          padok-observer:
            ansible_host: ${module.ec2_instance[0].public_ip}
            ansible_ssh_private_key_file: ~/.ssh/id_rsa
            ansible_user: illia
          padok-target-1:
            ansible_host: ${module.ec2_instance[1].public_ip}
            ansible_ssh_private_key_file: ~/.ssh/id_rsa
            ansible_user: illia
          padok-target-2:
            ansible_host: ${module.ec2_instance[2].public_ip}
            ansible_ssh_private_key_file: ~/.ssh/id_rsa
            ansible_user: illia
  EOT
  filename = "/home/illia/StepProject/ansible/ansible-monitoring-stack/inventories/hosts.yml"
}

resource "local_file" "vars" {
  depends_on = [module.ec2_instance]

  content = <<-EOT
  scrape_configs:
  - job_name: prometheus
    scrape_interval: 30s
    static_configs:
    - targets: ["localhost:9090"]

  - job_name: node-exporter
    scrape_interval: 30s
    static_configs:
    - targets: ["${module.ec2_instance[0].public_ip}:9100", "${module.ec2_instance[1].public_ip}:9100", "${module.ec2_instance[2].public_ip}:9100"]

  - job_name: cadvisor
    scrape_interval: 30s
    static_configs:
    - targets: ["${module.ec2_instance[1].public_ip}:9101", "${module.ec2_instance[2].public_ip}:9101"]
  EOT
  filename = "/home/illia/StepProject/ansible/ansible-monitoring-stack/roles/observer/files/prometheus_main.yml"
}


resource "null_resource" "run_ansible" {
  depends_on = [local_file.ansible_inventory]

  provisioner "local-exec" {
    command = "sleep 120 && ansible-playbook -T 300 -i /home/illia/StepProject/ansible/ansible-monitoring-stack/inventories/hosts.yml -u TheUserToExecuteWith /home/illia/StepProject/ansible/ansible-monitoring-stack/playbooks/monitoring.yml --vault-password-file /home/illia/StepProject/ansible/ansible-monitoring-stack/vault"
  }
}
