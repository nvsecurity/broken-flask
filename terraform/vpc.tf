resource "aws_vpc" "main" {
  #checkov:skip=CKV2_AWS_11:VPC Flow logs are unnecessary here
  #checkov:skip=CKV2_AWS_12:Internet accessibility is necessary for this demo
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.name} VPC"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Public Subnet and Internet Gateway
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name} Public Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name} VPC IG"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.main.id
  tags = {
      Name = "${var.name} Public Route Table"
  }
}

resource "aws_route" "route_igw" {
  route_table_id         = aws_route_table.rt_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.rt_public.id
}

# ---------------------------------------------------------------------------------------------------------------------
# Private Subnet and NAT Gateway
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.name} Private Subnet ${count.index + 1}"
  }
}


resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.name} NAT EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.gw]
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name} Private Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  timeouts {
    create = "5m"
  }
}