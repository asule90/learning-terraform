data "aws_vpc" "default" {
  id = var.vpc_id
}

resource "aws_instance" "web" {
  ami           = var.image_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [
    module.web_sg.security_group_id
  ]

  # subnet_id = data.aws_vpc.default.public_subnets[0]

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "HelloWorld"
  }
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  vpc_id = data.aws_vpc.default.id
  name    = "web_sg"

  ingress_rules = [
    "http-80-tcp",
    "https-443-tcp",
    "ssh-tcp"
  ]

  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = [
    "all-all",
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
}
