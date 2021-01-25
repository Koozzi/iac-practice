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

그리고 internal부분에 true로 설정을 한다면 내부 프라이빗 네트워크를 사용하겠다는 뜻이다. false로 지정해서 외부와 통신할 수 있게 하자.

~~~
security_groups    = ["sg-03b15fd39b667c996"]
-> 이렇게 하면 안 됩니다용^^
~~~

이제는 ALB에 할당되는 대상 그룹을 지정해보자
~~~
resource "aws_alb_target_group" "koozzi_alb_target" {
  name     = "koozzi-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-3c1bbe57"
}

resource "aws_lb_target_group_attachment" "target_attachment_1" {
  target_group_arn = "${aws_alb_target_group.koozzi_alb_target.arn}"
  target_id = "i-0c28891d4570b9ce4"
  port = 80
}

resource "aws_lb_target_group_attachment" "target_attachment_2" {
  target_group_arn = "${aws_alb_target_group.koozzi_alb_target.arn}"
  target_id = "i-05a527a1c9f03e9f4"
  port = 80
}
~~~

먼저 `koozzi_alb_target`라는 대상 그룹을 생성한다. 여기서 healthy check은 따로 지정을 하지 않으면 아래와 같이 default로 설정이 된다. 

<img width="830" alt="스크린샷 2021-01-26 오전 2 11 27" src="https://user-images.githubusercontent.com/46708207/105739767-cd9a7500-5f7b-11eb-8f37-d7c0d3484665.png">

다음으로는 새로 생성한 대상 그룹에 인스턴스를 집어 넣어야 하는데 사실 아래와 같이 resource를 한 번만 사용해서 여러 인스턴스를 붙일 수 있지만 우선 지금은 resource를 두 번 사용해서 전에 생성한 두 개의 인스턴스를 대상 그룹에 넣어 줬다.

<img width="655" alt="스크린샷 2021-01-26 오전 2 13 25" src="https://user-images.githubusercontent.com/46708207/105740005-14886a80-5f7c-11eb-887e-0f615b307347.png">

다음으로 ALB listener를 구성해서 들어오는 트래픽을 target group으로 보낼 수 있도록 해보자. 

~~~
resource "aws_alb_listener" "koozzi-listener" {
  load_balancer_arn = aws_alb.koozzi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.koozzi_alb_target.arn
  }
}
~~~

HTTP프로토콜 80번 포트를 사용해서 해당 로드밸런서에 접근을 하면 `koozzi_alb_target`이라는 대상 그룹으로 트래픽을 전송하게 설정한다.

마지막으로 테스트

테스트 진행방식

1. 인스턴스 두 개를 모두 띄운다
2. 인스턴스 안에서 apache2를 설치하고 -tail을 사용해서 실시간 접근 내역을 확인한다.
3. ALB 주소로 1초에 한 번씩 접속한다.
4. 두 개의 인스턴에 번갈아가면서 접속 로그가 찍히면 성공
5. 성공했으면 빨리 삭제하자 요금나간다 ^^ `terraform destroy`

![ezgif com-gif-maker (2)](https://user-images.githubusercontent.com/46708207/105745549-be1e2a80-5f81-11eb-97f8-0662a15f5fa3.gif)
