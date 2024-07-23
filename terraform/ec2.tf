resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.small"

  tags = {
    Name = "broken-flask"
  }
  subnet_id            = aws_subnet.private_subnets[0].id
  user_data            = templatefile("${path.module}/userdata.sh.tpl", {})
  iam_instance_profile = aws_iam_instance_profile.flask.name
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  vpc_security_group_ids = [aws_security_group.web.id]
}


resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_alb_target_group.this.arn
  target_id        = aws_instance.web.private_ip
  port             = 4000
}

resource "aws_security_group" "web" {
  name_prefix = "broken-flask-web-sg"
  vpc_id      = aws_vpc.main.id
  description = "Web server Security Group"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "web_ingress_4000" {
  description       = "Allow inbound traffic on port 4000 where the app is hosted"
  protocol          = "tcp"
  from_port         = 4000
  security_group_id = aws_security_group.web.id
  to_port           = 4000
  type              = "ingress"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "web_egress" {
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}