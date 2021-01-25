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
  key_name      = "<기존 키 이름>"
  tags = {
	  Name = "example-ec2"
  }
}
~~~

`key_name`에 기존에 존재하던 key_pair의 이름을 그냥 넣어주면 되는 것이었다. 

그리고 추가로 security group과 subnet정보도 넣어주었다.
~~~
resource "aws_instance" "example_ec2" {
  ami                    = "ami-0e67aff698cb24c1d"
  instance_type          = "t2.micro"
  key_name               = "alb-study"
  subnet_id              = "subnet-aad402c1"
  vpc_security_group_ids = [
    aws_security_group.ssh_http.id,
  ]
  tags = {
	  Name = "example-ec2"
  }
}
~~~
위의 리소스 코드를 보면 vpc를 따로 설정해주지 않았다. 대신 `vpc_security_group_ids`에 특정 security group을 넣어줌으로써 vpc를 할당할 수 있는 것 같다. 왜냐하면 vpc안에서 최대 5개의 security group를 생성할 수 있는데, 내가 특정 securit group를 할당한다면 Terraform이 자동으로 내가 선택한 security group이 속한 vpc로 설정해주지 않을까라는 생각을 한다. 

Application Load Balancer를 붙이기 위해서 다른 subnet에 ec2를 하나 더 생성해주자.

<img width="846" alt="스크린샷 2021-01-25 오전 1 36 50" src="https://user-images.githubusercontent.com/46708207/105636891-cd33a880-5ead-11eb-8fc5-637585518ba5.png">

> 아 subnet id를 가져온다든가, 기존의 리소스를 가져올 때 뭔가 기똥찬 방법으로 가져오고 싶은데, 뭐가 있을까

### 2021.01.26
오늘은 Terraform으로 Application Load Balancer를 생성하고 어제 만든 두 개의 EC2(가용영역 a, 가용영역 b)를 붙여볼 것이다.

처음에는 완벽하지 않은, 다시 말해 필수 설정만 완료한 ALB를 생성해본다. ALB에 관한 tf파일을 새로 만들어줬다.
~~~
resource "aws_alb" "koozzi-alb" {
  name               = "koozzi-alb"
  internal           = false
  subnets            = ["subnet-aad402c1", "subnet-00447e4c"]
  security_groups    = ["sg-03b15fd39b667c996"]
  load_balancer_type = "application"
  
  tags = {
    Name = "koozzi-alb"
  }
}
~~~
여기서 신경써야 할 부분은 subnets과 security_groups이다. 대괄호로 안에 해당하는 id를 넣어야 한다. 만약에 아래와 같이 설정을 한다면 오류가 뜰 것이다.

~~~
security_groups    = ["sg-03b15fd39b667c996"]
-> 이렇게 하면 안 됩니다용^^
~~~