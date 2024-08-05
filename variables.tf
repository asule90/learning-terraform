variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "image_id" {
  description = "Ubuntu image"
#  ubuntu origin
#  default     = "ami-060e277c0d4cce553"
#  ubuntu 24 docker nginx
  default    = "ami-0da3fbcbba1d39305"
}

variable "vpc_id" {
  description = "Default VPC ID"
  default     = "vpc-0c8af7f7261ed81fc"
}
