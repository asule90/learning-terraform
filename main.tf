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
}


module "web_autoscaling" {
  source   = "terraform-aws-modules/autoscaling/aws"
  version  = "7.7.0"
  # insert the 1 required variable here
  name     = "web"
  min_size = 1
  max_size = 2

  vpc_zone_identifier = module.web_vpc.public_subnets
  target_group_arns   = module.web_alb.target_groups.target_group_arns
  security_groups     = [module.web_sg.security_group_id]
  instance_type       = var.instance_type
  image_id            = var.image_id
  key_name            = aws_key_pair.deployer.key_name
}

module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id  = module.web_vpc.vpc_id
  subnets = module.web_vpc.public_subnets

  security_groups = [module.web_sg.security_group_id]

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex-instance"
      }
    }
    # ex-https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

    #   forward = {
    #     target_group_key = "ex-instance"
    #   }
    # }
  }

  target_groups = { 
    asg = {
      name              = "asg-tg"
      port              = 8080
      protocol          = "HTTP"
      vpc_id            = module.web_vpc.vpc_id
    }

  }

  tags = {
    Environment = "Development"
    Project     = "Example"
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

  # vpc_id = data.aws_vpc.default.id
}
