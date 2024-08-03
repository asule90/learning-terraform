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

resource "aws_instance" "web" {
  ami           = "ami-060e277c0d4cce553"
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}
