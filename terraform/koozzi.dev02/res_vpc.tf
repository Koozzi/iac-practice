# VPC

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
      "Name" = "main_vpc"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
      "Name" = "main_igw"
  }
}

# Public Subnet and Routing Table

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public_subnet_a"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public_subnet_c"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
      "Name" = "public_route_table"
  }
}

resource "aws_route_table_association" "route_table_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "route_table_association_c" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.main_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# # NAT Gateway

# resource "aws_eip" "nat_a" {
#   vpc = true

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_eip" "nat_c" {
#   vpc = true

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_nat_gateway" "nat_gateway_a" {
#   allocation_id = aws_eip.nat_a.id
#   subnet_id     = aws_subnet.public_subnet_a.id

#   tags = {
#       "Name" = "nat_gateway_a"
#   }
# }

# resource "aws_nat_gateway" "nat_gateway_c" {
#   allocation_id = aws_eip.nat_c.id
#   subnet_id     = aws_subnet.public_subnet_c.id

#   tags = {
#       "Name" = "nat_gateway_c"
#   }
# }

# # Private Subnet and Routing Table

# resource "aws_subnet" "private_subnet_a" {
#   vpc_id            = aws_vpc.main_vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "ap-northeast-2a"

#   tags = {
#     "Name" = "private_subnet_a"
#   }
# }

# resource "aws_subnet" "private_subnet_c" {
#   vpc_id            = aws_vpc.main_vpc.id
#   cidr_block        = "10.0.3.0/24"
#   availability_zone = "ap-northeast-2c"

#   tags = {
#     "Name" = "private_subnet_c"
#   }
# }

# resource "aws_route_table" "private_route_table_a" {
#   vpc_id = aws_vpc.main_vpc.id

#   tags = {
#     "Name" = "private_route_table_a"
#   }
# }

# resource "aws_route_table" "private_route_table_c" {
#   vpc_id = aws_vpc.main_vpc.id

#   tags = {
#     "Name" = "private_route_table_c"
#   }
# }

# resource "aws_route_table_association" "private_route_table_a" {
#   subnet_id      = aws_subnet.private_subnet_a.id
#   route_table_id = aws_route_table.private_route_table_a.id
# }

# resource "aws_route_table_association" "private_route_table_c" {
#   subnet_id      = aws_subnet.private_subnet_c.id
#   route_table_id = aws_route_table.private_route_table_c.id
# }

# resource "aws_route" "private_nat_a" {
#   route_table_id         = aws_route_table.private_route_table_a.id
#   nat_gateway_id         = aws_nat_gateway.nat_gateway_a.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_route" "private_nat_c" {
#   route_table_id         = aws_route_table.private_route_table_c.id
#   nat_gateway_id         = aws_nat_gateway.nat_gateway_c.id
#   destination_cidr_block = "0.0.0.0/0"
# }