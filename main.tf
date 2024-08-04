data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default     = true
  cidr_block  = "172.31.0.0/16"
}

resource "aws_instance" "web" {
  ami           = "ami-060e277c0d4cce553"
  instance_type = var.instance_type
  vpc_security_group_ids = [
    module.web_sg.security_group_id,
    aws_security_group.ssh.id
  ]
  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "HelloWorld"
  }
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"
  name    = "web_new"
  ingress_rules = [
    "http-80-tcp",
    "https-443-tcp"
  ]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = [
    "all-all",
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]

  vpc_id = data.aws_vpc.default.id
}