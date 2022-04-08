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
