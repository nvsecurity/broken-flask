data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

data "aws_route53_zone" "zone" {
  name = var.domain_name
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

