# default vpc
# ec2 for my study
resource "aws_instance" "my_ec2_for_study" {
  ami                    = var.AMI_UBUNTU_1804
  key_name               = var.DEFAULT_KEY
  subnet_id              = var.DEFAULT_SUBNET_A
  instance_type          = "t2.xlarge"

  vpc_security_group_ids = [
    var.MY_SECURITY_GROUP,
  ]

  tags = {
	  Name = "My EC2 for Study"
  }
}