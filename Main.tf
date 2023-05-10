#Carter VPC
resource "aws_vpc" "carter-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "carter-vpc"
  }
}


#Carter Subnet
resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.carter-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "public-sub"
  }
}


resource "aws_subnet" "private-sub" {
  vpc_id     = aws_vpc.carter-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "private-sub"
  }
}


# Carter Public Route Table

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.carter-vpc.id

  tags = {
    Name = "public-route-table"
  }
}


# Carter Private Route Table

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.carter-vpc.id

  tags = {
    Name = "private-route-table"
  }
}


# Carter Internet Gateway

resource "aws_internet_gateway" "carter-igw" {
  vpc_id = aws_vpc.carter-vpc.id

  tags = {
    Name = "carter-igw"
  }
}


# Carter subnet association

resource "aws_route_table_association" "private-route-table-association" {
  subnet_id      = aws_subnet.private-sub.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "public-route-table-association" {
  subnet_id      = aws_subnet.public-sub.id
  route_table_id = aws_route_table.public-route-table.id
}


# Carter igw route

resource "aws_route" "carter-igw-association" {
  route_table_id            = aws_route_table.public-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.carter-igw.id 
  }


# Carter Elastic IP

resource "aws_eip" "carter-eip" {
  vpc      = true

  tags = {
    Name = "carter-eip"
  }
}


# Carter Nat gateway

resource "aws_nat_gateway" "carter-nat-gateway" {
  allocation_id = aws_eip.carter-eip.id
  subnet_id     = aws_subnet.public-sub.id

  tags = {
    Name = "carter-nat-gateway"
  }
}


# Carter Nat Gateway association

resource "aws_route" "carter-ngw-association" {
  route_table_id            = aws_route_table.private-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.carter-nat-gateway.id 
  }
