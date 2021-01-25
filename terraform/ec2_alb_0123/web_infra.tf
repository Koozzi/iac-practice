resource "aws_security_group" "ssh_http" {
	name        = "allow_ssh_http_from_all"
	description = "Allow SSH and HTTP Port from all"

	ingress	{
		from_port   = 80
		to_port     = 80
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress	{
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
    Name = "koozzi-sg"
  }
}

resource "aws_instance" "example_ec2-a" {
  ami                    = "ami-0e67aff698cb24c1d"
  instance_type          = "t2.micro"
  key_name               = "alb-study"
  subnet_id              = "subnet-aad402c1"
  vpc_security_group_ids = [
    aws_security_group.ssh_http.id,
  ]
  tags = {
	  Name = "example-ec2-a"
  }
}

resource "aws_instance" "example_ec2-c" {
  ami                    = "ami-0e67aff698cb24c1d"
  instance_type          = "t2.micro"
  key_name               = "alb-study"
  subnet_id              = "subnet-00447e4c"
  vpc_security_group_ids = [
    aws_security_group.ssh_http.id,
  ]
  tags = {
	  Name = "example-ec2-c"
  }
}