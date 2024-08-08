variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type = string
}

variable "key_name" {
  description = "ssh key pair name"
  type = string
}

variable "public_subnet_id" {
  description = "Subnet ID for the public subnet"
  type = string
}

variable "public_sg_id" {
  description = "value of public security group"
  type = string
}