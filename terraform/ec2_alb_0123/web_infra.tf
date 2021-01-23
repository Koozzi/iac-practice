# resource "aws_key_pair" "web_admin" {
#   key_name = "web_admin"
#   public_key = file("~/.ssh/web_admin.pub")
# }

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