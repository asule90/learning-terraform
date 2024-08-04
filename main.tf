data "aws_vpc" "default" {
  default     = true
  cidr_block  = "172.31.0.0/16"
}

module "web_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "172.31.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  public_subnets  = ["172.31.16.0/20", "172.31.32.0/20", "172.31.0.0/20"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }

  map_public_ip_on_launch = true
}

resource "aws_instance" "web" {
  ami           = var.image_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [
    module.web_sg.security_group_id
  ]

  subnet_id = module.web_vpc.public_subnets[0]

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "HelloWorld"
  }
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  vpc_id = module.web_vpc.vpc_id
  name    = "web_new"

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
