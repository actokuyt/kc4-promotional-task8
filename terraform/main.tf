terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "./vpc"

  cidr_block = "10.0.0.0/16"
  vpc_name   = "github_actions"
}

module "igw" {
  source = "./igw"

  vpc_id = module.vpc.vpc_id
}

module "rt" {
  source = "./rt"

  vpc_id            = module.vpc.vpc_id
  gateway_id        = module.igw.gateway_id
  public_subnet_id  = module.subnet.subnet_id
}

module "eip" {
  source = "./eip"
}

module "subnet" {
  source = "./subnet"

  vpc_id = module.vpc.vpc_id
}

module "sg" {
  source = "./sg"

  vpc_id = module.vpc.vpc_id
}

module "nacl" {
  source = "./nacl"

  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./ec2"

  ami_id        = "ami-0932dacac40965a65"
  instance_type = "t2.medium"
  key_name      = "ec2ssh"
  public_sg_id  = module.sg.public_sg_id
  public_subnet_id = module.subnet.subnet_id
  private_key_path = var.private_key_path
}
