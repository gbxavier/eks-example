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
    "Name" = format(
      "${local.public_subnet_prefix}-%s",
      element(local.azs, count.index),
    )
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(local.azs, count.index)
  tags = {
    "Name" = format(
      "${local.private_subnet_prefix}-%s",
      element(local.azs, count.index),
    )
  }
}
