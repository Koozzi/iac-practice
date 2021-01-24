# Application Load Balancer and EC2 with Terraform

- EC2
- Application Load Balancer

### 2021.01.24
key pair는 전에 만들어 놨었고, 오늘 새로운 security group를 생성했다. 그런데 EC2 resource를 생성할 때, 기존에 있던 key pair는 어떻게 참조하지?

### 2021.01.25
검색을 하니까, 기존에 존재하는 리소스를 사용하려면 `terraform import` 명령어를 써야 한다고 하는데 아직까지는 이해를 잘 못하겠다. 계속 방법을 찾던 중 인도 사람의 유튜브를 보게 되었고 생각보다 간단하게 문제를 해결했다. 

~~~
resource "aws_instance" "example_ec2" {
  ami           = "ami-0e67aff698cb24c1d"
  instance_type = "t2.micro"
  key_name      = "terraform"
  tags = {
	  Name = "example-ec2"
  }
}
~~~

`key_name`에 기존에 존재하던 key_pair의 이름을 그냥 넣어주면 되는 것이었다. 