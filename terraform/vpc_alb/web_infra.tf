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

# Subnet

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

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    "Name" = "private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    "Name" = "private_subnet_c"
  }
}

# Public subnet's route table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
      "Name" = "public_route_table"
  }
}

resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.public_route_table.id
}

# Routeing Policy

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# NAT Gateway

resource "aws_eip" "nat_a" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_c" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
      "Name" = "nat_gateway_a"
  }
}

resource "aws_nat_gateway" "nat_gateway_c" {
  allocation_id = aws_eip.nat_c.id
  subnet_id     = aws_subnet.public_subnet_c.id

  tags = {
      "Name" = "nat_gateway_c"
  }
}

# Private subnet's route table

resource "aws_route_table" "private_route_table_a" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "private_route_table_a"
  }
}

resource "aws_route_table" "private_route_table_c" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "private_route_table_c"
  }
}

resource "aws_route_table_association" "private_route_table_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table_a.id
}

resource "aws_route_table_association" "private_route_table_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_route_table_c.id
}

# Routeing Policy

resource "aws_route" "private_nat_a" {
  route_table_id         = aws_route_table.private_route_table_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_a.id
}

resource "aws_route" "private_nat_c" {
  route_table_id         = aws_route_table.private_route_table_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_c.id
}

# Security Group

resource "aws_security_group" "public_security_group" {
  name   = "public_security_group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "public_secuirty_group"
  }
}

resource "aws_security_group" "private_security_group" {
  name   = "private_security_group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    security_groups = [
      "${aws_security_group.public_security_group.id}"
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [
      "${aws_security_group.public_security_group.id}"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "private_secuirty_group"
  }
}

# EC2 instances

resource "aws_instance" "public_ec2_a" {
  ami                    = "ami-0e67aff698cb24c1d"
  key_name               = "alb-study"
  subnet_id              = aws_subnet.public_subnet_a.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.public_security_group.id,
  ]

  tags = {
	  Name = "public_ec2_a"
  }
}

resource "aws_instance" "public_ec2_c" {
  ami                    = "ami-0e67aff698cb24c1d"
  key_name               = "alb-study"
  subnet_id              = aws_subnet.public_subnet_c.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.public_security_group.id,
  ]

  tags = {
	  Name = "public_ec2_c"
  }
}

resource "aws_instance" "private_ec2_a" {
  ami                    = "ami-0e67aff698cb24c1d"
  key_name               = "alb-study"
  subnet_id              = aws_subnet.private_subnet_a.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.private_security_group.id,
  ]

  tags = {
	  Name = "private_ec2_a"
  }
}

resource "aws_instance" "private_ec2_c" {
  ami                    = "ami-0e67aff698cb24c1d"
  key_name               = "alb-study"
  subnet_id              = aws_subnet.private_subnet_c.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.private_security_group.id,
  ]

  tags = {
	  Name = "private_ec2_c"
  }
}

# Application Load Balancer

resource "aws_alb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_c.id
  ]

  security_groups = [
    aws_security_group.public_security_group.id
  ]

  tags = {
    "Name" = "public_alb"
  }
}

resource "aws_alb_target_group" "public_alb_target" {
  name     = "public-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_alb_target_group_attachment" "target_attachment_1" {
  target_group_arn = "${aws_alb_target_group.public_alb_target.arn}"
  target_id        = aws_instance.public_ec2_a.id 
  port             = 80
}

resource "aws_alb_target_group_attachment" "target_attachment_2" {
  target_group_arn = "${aws_alb_target_group.public_alb_target.arn}"
  target_id        = aws_instance.public_ec2_c.id 
  port             = 80
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.public_alb_target.arn
  }
}