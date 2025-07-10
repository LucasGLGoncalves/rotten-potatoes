# VPC
resource "aws_vpc" "avg-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags                 = { Name = "main-vpc" }
}

# Subnet pública
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.avg-vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "public-subnet" }
}

# Subnet privada
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.avg-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.avg-vpc.id
  tags   = { Name = "main-igw" }
}

# Internet Gateway Attachment
resource "aws_internet_gateway_attachment" "igw-attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.avg-vpc.id
}

# Elastic IP to NatGateway
resource "aws_eip" "avg_nat_eip" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "avg_nat_eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "avg_nat_gtw" {
  allocation_id = aws_eip.avg_nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Route table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.avg-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route table privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.avg-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.avg_nat_gtw.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}