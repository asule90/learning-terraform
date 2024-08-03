data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "id"
    values = ["ami-060e277c0d4cce553"]
  }
  # filter {
  #   name   = "name"
  #   values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  # }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = "t3.nano"

  tags = {
    Name = "HelloWorld"
  }
}
