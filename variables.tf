variable "instance_type" {
 description = "Type of EC2 instance to provision"
 default     = "t3.nano"
}

variable "image_id" {
 description = "Ubuntu Image"
 default     = "ami-060e277c0d4cce553"
}
