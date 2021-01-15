resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "koozzi-vpc"
  }
}

resource "aws_subnet" "first_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.1.0/24"

	availability_zone = "ap-northeast-2a"

	tags ={
		Name = "koozzi-subnet-1"
	}
}

resource "aws_subnet" "second_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.2.0/24"

	availability_zone = "ap-northeast-2b"

	tags = {
		Name = "koozzi-subnet-2"
	}
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "main"
	}
}

resource "aws_route_table" "route_table" {
	vpc_id = aws_vpc.main.id

	tags = {
		Name = "main"
	}
}

resource "aws_route_table_association" "route_table_association_1" {
	subnet_id = aws_subnet.first_subnet.id
	route_table_id = aws_route_table.route_table.id
}


resource "aws_route_table_association" "route_table_association_2" {
	subnet_id = aws_subnet.second_subnet.id
	route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "first_private_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.3.0/24"

	availability_zone = "ap-northeast-2a"

	tags = {
		Name = "koozzi-private-01"
	}
}

resource "aws_subnet" "second_private_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "10.0.4.0/24"

	availability_zone = "ap-northeast-2b"

	tags = {
		Name = "koozzi-private-02"
	}
}