resource "aws_vpc" "vpc-adnan" {
  cidr_block       = "11.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-adnan"
  }
}

resource "aws_internet_gateway" "igw-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  tags = {
    Name = "igw-adnan"
  }
}

resource "aws_subnet" "publicsubnet1-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = "11.0.1.0/26"
  availability_zone = "us-east-1a"

  tags = {
    Name = "publicsubnet1-adnan"
  }
}

resource "aws_subnet" "publicsubnet2-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = "11.0.2.0/26"
  availability_zone = "us-east-1b"

  tags = {
    Name = "publicsubnet2-adnan"
  }
}

resource "aws_subnet" "privatesubnet-adnan" {
  vpc_id            = aws_vpc.vpc-adnan.id
  cidr_block        = "11.0.3.0/26"
  availability_zone = "us-east-1a"

  tags = {
    Name = "privatesubnet-adnan"
  }
}

resource "aws_route_table" "public-rt-adnan" {
  vpc_id = aws_vpc.vpc-adnan.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-adnan.id
  }

  tags = {
    Name = "public-rt-adnan"
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

  tags = {
    Name = "private-rt-adnan"
  }
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

  tags = {
    Name = "alb-sg-adnan"
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

  tags = {
    Name = "ec2-sg-adnan"
  }
}