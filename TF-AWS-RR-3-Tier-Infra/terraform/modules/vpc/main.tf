locals {
  nat_gateway_subnet = var.single_nat_gateway ? {
    primary = values(var.public_subnet_cidrs)[0]
  } : var.public_subnet_cidrs
}

# Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-vpc"
    }
  )
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.public_subnet_cidrs

  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = each.value
  availability_zone       = var.subnet_az_mapping[each.key]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}"
      Tier = "public"
    }
  )
}

# Web Private Subnets (App Tier - Frontend)
resource "aws_subnet" "web" {
  for_each = var.web_subnet_cidrs

  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = each.value
  availability_zone = var.subnet_az_mapping[each.key]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}"
      Tier = "web"
    }
  )
}

# Database Isolated Subnets (Data Tier)
resource "aws_subnet" "database" {
  for_each = var.database_subnet_cidrs

  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = each.value
  availability_zone = var.subnet_az_mapping[each.key]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}"
      Tier = "database"
    }
  )
}

# Elastic IP for NAT GWs
resource "aws_eip" "nat" {
  # for_each = var.enable_nat_gateway ? var.public_subnet_cidrs : {} # for multiple NAT GWs
  for_each = var.enable_nat_gateway ? local.nat_gateway_subnet : {}

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}-nat-eip"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

# NAT GWs
resource "aws_nat_gateway" "main" {
  #  for_each = var.enable_nat_gateway ? var.public_subnet_cidrs : {} # For multiple NAT GWs
  for_each = var.enable_nat_gateway ? local.nat_gateway_subnet : {}

  # for for_each usage
  /* 
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id 
*/

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = var.single_nat_gateway ? values(aws_subnet.public)[0].id : aws_subnet.public[each.key].id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}-nat-gw"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-public-rtb"
      Tier = "Public"
    }
  )
}

# Route for Public Subnets to IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = var.public_subnet_cidrs

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Route Tables for Web Private Subnets
resource "aws_route_table" "web" {
  #  for_each = var.enable_nat_gateway ? var.web_subnet_cidrs : {} # For multiple NAT GWs
  for_each = var.single_nat_gateway ? {
    shared = "shared"
  } : var.web_subnet_cidrs

  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-${each.key}-web-rtb"
      Tier = "web"
    }
  )
}

# Route for Web Subnets to NAT GW
resource "aws_route" "web_nat" {
  /*
  # for_each               = var.enable_nat_gateway ? var.web_subnet_cidrs : {} # For multiple NAT GWs
  route_table_id         = aws_route_table.web[each.key].id
  */
  for_each = aws_route_table.web

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  # For multiple NAT GWs
  # nat_gateway_id         = aws_nat_gateway.main[var.nat_gateway_subnet_mapping[each.key]].id
  nat_gateway_id = var.single_nat_gateway ? values(aws_nat_gateway.main)[0].id : aws_nat_gateway.main[each.key].id
}

# Associate Web Subnets with Public Route Table
resource "aws_route_table_association" "web" {
  for_each       = var.web_subnet_cidrs
  subnet_id      = aws_subnet.web[each.key].id
  route_table_id = var.single_nat_gateway ? values(aws_route_table.web)[0].id : aws_route_table.web[each.key].id
}

# Route Tables for Database Subnets (No Internet Access)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project}-database-rtb"
      Tier = "database"
    }
  )
}

# Associate Database Subnets with Database Route Table
resource "aws_route_table_association" "database" {
  for_each       = var.database_subnet_cidrs
  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database.id
}