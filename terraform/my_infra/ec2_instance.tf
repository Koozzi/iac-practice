resource "aws_instance" "public_a" {
  ami                    = var.AMI_AWS_LINUX
  key_name               = var.DEFAULT_KEY
  subnet_id              = aws_subnet.public_subnet_a.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.public_security_group.id
  ]

  tags = {
	  Name = "Public A Instance"
  }
}

resource "aws_instance" "public_c" {
  ami                    = var.AMI_AWS_LINUX
  key_name               = var.DEFAULT_KEY
  subnet_id              = aws_subnet.public_subnet_c.id
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.public_security_group.id
  ]

  tags = {
	  Name = "Public C Instance"
  }
}