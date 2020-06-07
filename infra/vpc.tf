#creating VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Cervian VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Cervian-igw"
  }
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Cervian default table"
  }
}

#Creating subnets
resource "aws_subnet" "Cervian_public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Public1"
  }
}

resource "aws_subnet" "Cervian_public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Public2"
  }
}

resource "aws_subnet" "Cervian_public3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.8.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Public3"
  }
}

resource "aws_subnet" "Cervian_private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Private1"
  }
}

resource "aws_subnet" "Cervian_private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Private2"
  }
}

resource "aws_subnet" "Cervian_private3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.24.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Private3"
  }
}

resource "aws_subnet" "Cervian_data1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.32.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Data1"
  }
}

resource "aws_subnet" "Cervian_data2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.36.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Data2"
  }
}

resource "aws_subnet" "Cervian_data3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.40.0/22"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Cervian-Data3"
  }
}