resource "aws_vpc" "vpc-adnan" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
  }
}

resource "aws_internet_gateway" "igw-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  tags = {
    Name = "${var.project_name}-igw-${var.environment}"
  }
}

# -------------------------------------------------------
# Public Subnets
# -------------------------------------------------------
resource "aws_subnet" "publicsubnet1-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "${var.project_name}-public-subnet-1-${var.environment}"
  }
}

resource "aws_subnet" "publicsubnet2-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.availability_zone_2

  tags = {
    Name = "${var.project_name}-public-subnet-2-${var.environment}"
  }
}

# -------------------------------------------------------
# Private Subnets
# -------------------------------------------------------
resource "aws_subnet" "privatesubnet1-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "${var.project_name}-private-subnet-1-${var.environment}"
  }
}

resource "aws_subnet" "privatesubnet2-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.availability_zone_2

  tags = {
    Name = "${var.project_name}-private-subnet-2-${var.environment}"
  }
}

# -------------------------------------------------------
# NAT Gateway — gives ECS instances in private subnets
# outbound internet access to pull ECR images and reach
# AWS APIs (CloudWatch Logs, Secrets Manager, etc.)
# -------------------------------------------------------
resource "aws_eip" "nat-adnan" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${var.environment}"
  }
}

resource "aws_nat_gateway" "nat-adnan" {
  allocation_id = aws_eip.nat-adnan.id
  subnet_id     = aws_subnet.publicsubnet1-adnan.id

  tags = {
    Name = "${var.project_name}-nat-${var.environment}"
  }

  depends_on = [aws_internet_gateway.igw-adnan]
}

# -------------------------------------------------------
# Route Tables
# -------------------------------------------------------
resource "aws_route_table" "public-rt-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-adnan.id
  }

  tags = {
    Name = "${var.project_name}-public-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "public-rt-association1-adnan" {
  subnet_id      = aws_subnet.publicsubnet1-adnan.id
  route_table_id = aws_route_table.public-rt-adnan.id
}

resource "aws_route_table_association" "public-rt-association2-adnan" {
  subnet_id      = aws_subnet.publicsubnet2-adnan.id
  route_table_id = aws_route_table.public-rt-adnan.id
}

resource "aws_route_table" "private-rt-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-adnan.id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${var.environment}"
  }
}

resource "aws_route_table_association" "private-rt-association1-adnan" {
  subnet_id      = aws_subnet.privatesubnet1-adnan.id
  route_table_id = aws_route_table.private-rt-adnan.id
}

resource "aws_route_table_association" "private-rt-association2-adnan" {
  subnet_id      = aws_subnet.privatesubnet2-adnan.id
  route_table_id = aws_route_table.private-rt-adnan.id
}

# -------------------------------------------------------
# Security Group: ALB — internet-facing
# -------------------------------------------------------
resource "aws_security_group" "alb-sg-adnan" {
  name        = "alb-sg-adnan"
  description = "Allow HTTP/HTTPS inbound to ALB from internet"
  vpc_id      = aws_vpc.vpc-adnan.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-adnan"
  }
}

# -------------------------------------------------------
# Security Group: ECS EC2 instances
# Accepts traffic from ALB on container port + ephemeral range
# -------------------------------------------------------
resource "aws_security_group" "ecs-sg-adnan" {
  name        = "ecs-sg-adnan"
  description = "Allow traffic from ALB to ECS instances"
  vpc_id      = aws_vpc.vpc-adnan.id

  ingress {
    description     = "Nginx/client port from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-adnan.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg-adnan"
  }
}

# -------------------------------------------------------
# Security Group: RDS — MySQL from ECS instances ONLY
# -------------------------------------------------------
resource "aws_security_group" "rds-sg-adnan" {
  name        = "rds-sg-adnan"
  description = "Allow MySQL only from ECS instances"
  vpc_id      = aws_vpc.vpc-adnan.id

  ingress {
    description     = "MySQL from ECS instances only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-sg-adnan.id]
  }

  ingress {
    description     = "MySQL from Bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-sg-adnan.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-adnan"
  }
}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_public_ip = chomp(data.http.my_public_ip.response_body)
}

# -------------------------------------------------------
# Security Group: Bastion Host
# -------------------------------------------------------
resource "aws_security_group" "bastion-sg-adnan" {
  name        = "bastion-sg-adnan"
  description = "Bastion host security group"
  vpc_id      = aws_vpc.vpc-adnan.id

  ingress {
    description = "SSH for Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_public_ip}/32"]
  }

  egress {
    description = "MySQL to RDS in private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_1_cidr, var.private_subnet_2_cidr]
  }

  egress {
    description = "HTTPS outbound for package updates, AWS API calls"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg-adnan"
  }
}

# -------------------------------------------------------
# DB Subnet Group (required by RDS)
# -------------------------------------------------------
resource "aws_db_subnet_group" "rds-adnan" {
  name        = "rds-subnet-group-adnan"
  description = "Subnet group for RDS in private subnets"
  subnet_ids = [
    aws_subnet.privatesubnet1-adnan.id,
    aws_subnet.privatesubnet2-adnan.id
  ]

  tags = {
    Name = "rds-subnet-group-adnan"
  }
}
