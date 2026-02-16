resource "aws_vpc" "vpc-adnan" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

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

resource "aws_subnet" "privatesubnet-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone_1

  tags = {
    Name = "${var.project_name}-private-subnet-${var.environment}"
  }
}

resource "aws_route_table" "public-rt-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-adnan.id
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
}

resource "aws_route_table_association" "private-rt-association-adnan" {
  subnet_id      = aws_subnet.privatesubnet-adnan.id
  route_table_id = aws_route_table.private-rt-adnan.id
}

resource "aws_security_group" "alb-sg-adnan" {
  name   = "alb-sg-adnan"
  vpc_id = aws_vpc.vpc-adnan.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "ec2-sg-adnan" {
  name   = "ec2-sg-adnan"
  vpc_id = aws_vpc.vpc-adnan.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-adnan.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-adnan.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
