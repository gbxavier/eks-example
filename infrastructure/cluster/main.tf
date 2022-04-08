resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "eks-example"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { "Name" = "eks-example-igw" }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  tags = {
    "Name" = "${local.public_subnet_prefix}-${local.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  tags = {
    "Name" = "${local.private_subnet_prefix}-${local.azs[count.index]}"
  }
}

resource "aws_eip" "nat" {
  count = length(local.azs)

  vpc = true

  tags = {
    "Name" = "${local.eip_prefix}-nat-${local.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "this" {
  count = length(local.azs)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    "Name" = "${local.ngw_prefix}-${local.azs[count.index]}"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${local.rt_prefix}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  # There are 3 routing tables because there are 3 NAT Gateways.
  # Each subnet uses the rt that points towards the NAT Gateway
  # that is located in the same AZ.
  count = length(aws_nat_gateway.this)

  vpc_id = aws_vpc.this.id

  tags = {
    "Name" = "${local.rt_prefix}-private-${local.azs[count.index]}"
  }
}

resource "aws_route" "private_nat_gateway" {
  count = length(aws_nat_gateway.this)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
