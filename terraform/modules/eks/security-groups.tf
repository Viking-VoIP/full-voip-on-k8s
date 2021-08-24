resource "aws_security_group" "sg_ssh_mgmt" {
  name        = "sg_ssh_mgmt"
  description = "Security group to allow SSH management"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sg_ssh_mgmt_rule" {
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_ssh_mgmt.id
}

## On the SIP-PROXY we should allow all UDP/TCP on ports 5060 and everything from SIP-B2BUA, BACKEND and SUPPORT and allow everything OUT
resource "aws_security_group" "sg_sip_proxy" {
  name        = "sg_sip_proxy"
  description = "Security group to allow 5060 to the SIP Proxy from the Public Internet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sg_sip_proxy_public_5060_rule_tcp" {
  type          = "ingress"
  from_port     = 5060
  to_port       = 5060
  protocol      = "tcp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_sip_proxy.id
}

resource "aws_security_group_rule" "sg_sip_proxy_public_5060_rule_udp" {
  type          = "ingress"
  from_port     = 5060
  to_port       = 5060
  protocol      = "udp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_sip_proxy.id
}

resource "aws_security_group_rule" "sg_sip_proxy_egress_rule" {
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_sip_proxy.id
}

## On the SIP-B2BUA we should allow all UDP on ports 16000-33000 and everything from SIP-PROXY, BACKEND and SUPPORT
resource "aws_security_group" "sg_sip_b2bua" {
  name        = "sg_sip_b2bua"
  description = "Security group to allow everything from the SIP Proxy SG and rtp from the Public Internet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sg_sip_b2bua_rtp_from_public_rule" {
  type          = "ingress"
  from_port     = 16000
  to_port       = 33000
  protocol      = "udp"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_sip_b2bua.id
}

resource "aws_security_group_rule" "sg_sip_b2bua_egress_rule" {
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_sip_b2bua.id
}

## On the BACKEND we should allow everything from SIP-PROXY, SIP_B2BUA and SUPPORT
resource "aws_security_group" "sg_backend_sg" {
  name        = "sg_backend_sg"
  description = "Security group for backend instances"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sg_sip_backend_egress_rule" {
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_backend_sg.id
}

## On the SUPPORT we should allow everything from SIP-PROXY, SIP_B2BUA and BACKEND

resource "aws_security_group" "sg_support_sg" {
  name        = "sg_support_sg"
  description = "Security group for support instances"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sg_sip_support_egress_rule" {
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.sg_support_sg.id
}