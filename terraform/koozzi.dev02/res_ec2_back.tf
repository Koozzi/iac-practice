resource "aws_instance" "ec2_backend" {
  ami                    = var.AMI_UBUNTU_1804
  key_name               = var.DEFAULT_KEY
  subnet_id              = var.SUBNET_A
  instance_type          = "t2.micro"

  vpc_security_group_ids = [
    var.MY_SECURITY_GROUP,
  ]

  tags = {
	  Name = "Backend Server"
  }
}