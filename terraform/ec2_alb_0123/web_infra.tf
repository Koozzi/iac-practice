resource "aws_security_group" "ssh_http" {
	name = "allow_ssh_http_from_all"
	description = "Allow SSH and HTTP Port from all"

	ingress	{
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress	{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
    Name = "koozzi-sg"
  }
}

resource "aws_instance" "example_ec2" {
  ami           = "ami-0e67aff698cb24c1d"
  instance_type = "t2.micro"
  key_name      = "terraform"
  tags = {
	  Name = "example-ec2"
  }
}