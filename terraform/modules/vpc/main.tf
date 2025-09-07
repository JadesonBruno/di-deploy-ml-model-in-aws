data "aws_availability_zones" "zones" {
  state = "available"
}


# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}


# Internet Gateway Resource
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}


# Public Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id  = aws_vpc.main.id
  cidr_block = "10.2.${count.index}.0/24" # 10.2.0.0/24 to 10.2.1.0/24
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.project_name}-${var.environment}-public-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "public"
    Terraform = "true"

  }
}


# Private Subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id = aws_vpc.main.id
  cidr_block = "10.2.${2 + count.index}.0/24" # 10.2.2.0/24 to 10.2.3.0/24
  availability_zone = data.aws_availability_zones.zones.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "private"
    Terraform = "true"
  }
}


# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(aws_subnet.private)

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-nat-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}


# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.private)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  connectivity_type = "public"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  count = length(aws_subnet.public)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-route-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "public"
    Terraform = "true"
  }
}


# Private Route Table
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-route-${substr(data.aws_availability_zones.zones.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "private"
    Terraform = "true"
  }
}


resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
