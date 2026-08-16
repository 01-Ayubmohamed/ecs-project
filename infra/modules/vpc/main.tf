resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_default_security_group" "vpc_sg" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-vpc-sg-locked-down"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
    vpc_id     = aws_vpc.main.id
    for_each = { for idx, ps in var.public_subnets : data.aws_availability_zones.available.names[idx] => ps }
    cidr_block = each.value.cidr_block
    availability_zone = each.key
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.name}-public-subnet-${each.key}"
    }
}

resource "aws_subnet" "private_subnet" {
    for_each = { for idx, ps in var.private_subnets : data.aws_availability_zones.available.names[idx] => ps }
    cidr_block = each.value.cidr_block
    availability_zone = each.key
    vpc_id     = aws_vpc.main.id
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.name}-private-subnet-${each.key}"
    }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }


    tags = {
      Name = "${var.name}-private-rt"
    }

}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_nat_gateway" "main" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_internet_gateway.main]
  availability_mode = "regional"

  tags = {
    Name = "${var.name}-nat-gw"
  }
}
