resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow http & https in. Allow everything out"

  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "web_http_in" {
  type         = "ingress"
  from_port    = 80
  to_port      = 80
  protocol     = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_https_in" {
  type         = "ingress"
  from_port    = 443
  to_port      = 443
  protocol     = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_everything_out" {
  type         = "egress"
  from_port    = 0
  to_port      = 0
  protocol     = "-1"
  cidr_blocks  = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "Allow ssh in"

  vpc_id = data.aws_vpc.default.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-demo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNUXbgqucYmLLkPCI8BVuZeYKSO86Ob+HuqoOqNwCIKpULatfu/4KDvV25eZ/IF1cx0E1qm4Nar/eMYc1HfOdLug6QneTYh5cWbtf4i7dN//Xgf/tQoQYRIiZXda8w9PLdaLZw117c0HUa9DYFR/QK7H7IK0mNsnAtV5nOmwKBcblMD7bvYZtKaVMKV0DZjm+0TCHpPBGiktemJEsFDuOF+qVh0eXE1E0bOT6ZjTm/LY4ksqt55gPvC6KnorPzYagcaCqJs8Oet+gQo1RlPEYt9gccD86FRDBai8VN02RaNDga12j0t+tUojZZRVY/f4X+unDytg9ote+K+wyRI9GVJ0JjJviJVpMy4s9hQriFq+RLjOfKgjVHmizSk++sONNjf0vvnD/COErGKVv77dBO+J2T/PDhB2GaQapOjLqwsLgBuhBE01aFOIAklaZBssrnjda50mil5LqgqEgUTFFiPcvR5Nh4FULpX/4qGd5yFNMWRc0wkXxh9VsFkeFSUitVcklMChhfWhD4bCEfY0FLgsHkwv26WDWlCvLibx4fnQFD9EJOMf2+yUKGLd7OabLgdtc64UICNKDPuBQUmFL+rVxsmW3h3XslTj+bNvP1n04jSLeusw/H6PEH9cRv4haV53OPg4Wd7LxuSaRr2hw+ftB3CQFp8rJZjFGpHlnZ1Q== sule@ABN-325"
}

resource "aws_security_group_rule" "web_ssh_in" {
  type         = "ingress"
  from_port    = 22
  to_port      = 22
  protocol     = "tcp"
  cidr_blocks  = [data.aws_vpc.default.cidr_block]

  security_group_id = aws_security_group.ssh.id
}