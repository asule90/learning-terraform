data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "web" {
  ami           = var.image_id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [
    module.web_sg.security_group_id
  ]
  subnet_id = tolist(data.aws_subnets.default.ids)[0]

  # subnet_id = data.aws_vpc.default.public_subnets[0]

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "HelloWorld"
  }
}


module "web_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id  = data.aws_vpc.default.id
  subnets = data.aws_subnets.default.ids 

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
        target_group_key = "ex_asg"
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
    ex_asg = {
      name_prefix      = "web-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = aws_instance.web.id
    }
    # There's nothing to attach here in this definition.
    # The attachment happens in the ASG module above
    # create_attachment     = false

  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
