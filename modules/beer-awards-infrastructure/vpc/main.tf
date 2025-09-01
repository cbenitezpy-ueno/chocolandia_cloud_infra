# VPC and Networking Sub-module for Beer Awards Infrastructure

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
    Type = "VPC"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
    Type = "Internet Gateway"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
    Type = "Public Subnet"
    Tier = "Public"
    AZ   = var.availability_zones[count.index]
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
    Type = "Private Subnet"
    Tier = "Private"
    AZ   = var.availability_zones[count.index]
  })
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-subnet-${count.index + 1}"
    Type = "Database Subnet"
    Tier = "Database"
    AZ   = var.availability_zones[count.index]
  })
}

# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
    Type = "DB Subnet Group"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
    Type = "NAT Gateway EIP"
  })

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
    Type = "NAT Gateway"
    AZ   = var.availability_zones[count.index]
  })

  depends_on = [aws_internet_gateway.main]
}

# VPN Gateway (optional)
resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpn-gateway"
    Type = "VPN Gateway"
  })
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  dynamic "route" {
    for_each = var.enable_vpn_gateway ? [1] : []
    content {
      cidr_block = "10.0.0.0/8"
      gateway_id = aws_vpn_gateway.main[0].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "Route Table"
    Tier = "Public"
  })
}

# Route Table for Private Subnets (one per AZ for NAT Gateway redundancy)
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  dynamic "route" {
    for_each = var.enable_vpn_gateway ? [1] : []
    content {
      cidr_block = "10.0.0.0/8"
      gateway_id = aws_vpn_gateway.main[0].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
    Type = "Route Table"
    Tier = "Private"
    AZ   = var.availability_zones[count.index]
  })
}

# Route Table for Database Subnets
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_vpn_gateway ? [1] : []
    content {
      cidr_block = "10.0.0.0/8"
      gateway_id = aws_vpn_gateway.main[0].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-rt"
    Type = "Route Table"
    Tier = "Database"
  })
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private Subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Route Table Associations - Database Subnets
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# VPC Endpoints for better security and cost optimization
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-s3-endpoint"
    Type = "VPC Endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecr-dkr-endpoint"
    Type = "VPC Endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ecr-api-endpoint"
    Type = "VPC Endpoint"
  })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-logs-endpoint"
    Type = "VPC Endpoint"
  })
}

# Data source for region
data "aws_region" "current" {}