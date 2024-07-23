resource "aws_security_group" "this" {
  name        = "${var.name}-lb-sg"
  vpc_id      = aws_vpc.main.id
  description = "Load balancer security group"
}

resource "aws_security_group_rule" "ingress_443" {
  description       = "Allow HTTPS traffic"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow outbound traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
