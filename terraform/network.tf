# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpc"
    }
  )
}


# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}


# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id = aws_vpc.main.id

  cidr_block = each.value.cidr

  availability_zone = data.aws_availability_zones.available.names[
    each.value.az_index
  ]

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${each.key}"

      "kubernetes.io/role/elb" = "1"
    }
  )
}


# --------------------------------------------------
# Private Subnets
# --------------------------------------------------

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.main.id

  cidr_block = each.value.cidr

  availability_zone = data.aws_availability_zones.available.names[
    each.value.az_index
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-${each.key}"

      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}


# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rt"
    }
  )
}


# --------------------------------------------------
# Public Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id = each.value.id

  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------
# Elastic IP for NAT Gateway
# --------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat-eip"
    }
  )
}


# --------------------------------------------------
# NAT Gateway
# --------------------------------------------------

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public["public-a"].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-nat"
    }
  )
}


# --------------------------------------------------
# Private Route Table
# --------------------------------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-private-rt"
    }
  )
}


# --------------------------------------------------
# Private Internet Route through NAT
# --------------------------------------------------

resource "aws_route" "private_nat" {
  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.main.id
}


# --------------------------------------------------
# Private Route Table Associations
# --------------------------------------------------

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id = each.value.id

  route_table_id = aws_route_table.private.id
}