terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

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

# Security Group da aplicação (libera HTTP, SSH)
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.avg-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group do banco de dados (permite apenas da aplicação)
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from app"
  vpc_id      = aws_vpc.avg-vpc.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NACL pública
resource "aws_network_acl" "public_acl" {
  vpc_id     = aws_vpc.avg-vpc.id
  subnet_ids = [aws_subnet.public.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "public-acl" }
}

# NACL privada
resource "aws_network_acl" "private_acl" {
  vpc_id     = aws_vpc.avg-vpc.id
  subnet_ids = [aws_subnet.private.id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_subnet.public.cidr_block
    from_port  = 3306
    to_port    = 3306
  }

  tags = { Name = "private-acl" }
}

# EC2 pública (aplicação)
resource "aws_instance" "app" {
  ami             = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public.id
  key_name        = "minha-chave-ssh"
  security_groups = [aws_security_group.app_sg.id]
  tags            = { Name = "app-server" }
}

# EC2 privada (banco de dados)
resource "aws_instance" "db" {
  ami             = "ami-0c02fb55956c7d316"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private.id
  key_name        = "minha-chave-ssh"
  security_groups = [aws_security_group.db_sg.id]
  tags            = { Name = "db-server" }
}
