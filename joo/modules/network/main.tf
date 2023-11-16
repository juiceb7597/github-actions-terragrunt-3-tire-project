################################################################################
# VPC
################################################################################

resource "aws_vpc" "main" {
  count = var.create_vpc ? 1 : 0

  cidr_block = var.cidr

  tags = merge(
    { "Name" = "${var.name}-${var.vpc_tags}" }
  )
}

################################################################################
# Publiс Subnets
################################################################################

resource "aws_subnet" "public" {
  count = var.multi_az && var.create_public_subnet ? 2 : var.create_public_subnet && var.create_vpc ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.public_subnet_cidr, count.index)
  tags = merge(
    { "Name" = "${var.name}-${element(var.public_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table" "public" {
  count = var.create_vpc && var.create_public_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    { "Name" = "${var.name}-${element(var.public_route_table_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "public" {
  count = var.multi_az && var.create_public_subnet ? 2 : var.create_public_subnet && var.create_vpc ? 1 : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_public_subnet ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

################################################################################
# WEB Subnets
################################################################################

resource "aws_subnet" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.web_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.web_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    { "Name" = "${var.name}-${element(var.web_route_table_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "web" {
  count = var.multi_az && var.create_web_subnet ? 2 : var.create_vpc && var.create_web_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.web[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

resource "aws_route" "web_nat_gateway" {
  count = var.multi_az && var.create_public_subnet && var.create_web_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_web_subnet && var.create_nat_gateway ? 1 : 0

  route_table_id         = element(aws_route_table.web[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this[*].id, count.index)
}

################################################################################
# WAS Subnets
################################################################################

resource "aws_subnet" "was" {
  count = var.multi_az && var.create_was_subnet ? 2 : var.create_vpc && var.create_was_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.was_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.was_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "was" {
  count = var.multi_az && var.create_was_subnet ? 2 : var.create_vpc && var.create_was_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.was[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

################################################################################
# DB Subnets
################################################################################

resource "aws_subnet" "db" {
  count = var.multi_az && var.create_db_subnet ? 2 : var.create_vpc && var.create_db_subnet ? 1 : 0

  vpc_id            = aws_vpc.main[0].id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.db_subnet_cidr, count.index)

  tags = merge(
    { "Name" = "${var.name}-${element(var.db_subnet_tags, count.index)}" }
  )
}

resource "aws_route_table_association" "db" {
  count = var.multi_az && var.create_db_subnet ? 2 : var.create_vpc && var.create_db_subnet ? 1 : 0

  subnet_id      = element(aws_subnet.db[*].id, count.index)
  route_table_id = element(aws_route_table.web[*].id, count.index)
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create_public_subnet ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    { "Name" = "${var.name}-${element(var.igw_tags, count.index)}" }
  )
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  count = var.multi_az && var.create_public_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_nat_gateway ? 1 : 0

  domain = "vpc"
  tags = merge(
    { "Name" = "${var.name}-${element(var.nat_eip_tags, count.index)}" }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.multi_az && var.create_public_subnet && var.create_nat_gateway ? 2 : var.create_public_subnet && var.create_nat_gateway ? 1 : 0

  allocation_id = element(aws_eip.nat[*].id, count.index)
  subnet_id     = element(aws_subnet.public[*].id, count.index)
  tags = merge(
    { "Name" = "${var.name}-${element(var.nat_gateway_tags, count.index)}" }
  )

  depends_on = [aws_internet_gateway.this]
}