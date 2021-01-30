# VPC, ALB, EC2, RDS with Terraform

### 목표 아키텍처
![스크린샷 2021-01-27 오전 3 28 34](https://user-images.githubusercontent.com/46708207/105888098-de1c1f80-604f-11eb-80c0-eb152be312b6.png)

### 2021.01.27

#### VPC > IGW > SUBNET(Multi-AZ) > EIP > NAT Gateway > Route Table

Route Table을 어떻게 구성하느냐에 따라서 public인지 private인지 결정난다. Public서브넷에 연결되어 있는 Route Table을 A라고 하고 Private서브넷에 연결되어 있는 Route Table을 B라고 하자.

우선 A테이블에서는 Destination이 '10.0.0.0/16'(VPC CIDR)일 때는 Target을 Local로 한다. 다시 말해서 VPC안에서 왔다리 갔다리 하겠다는 뜻이다. 그리고 Public서브넷이니까 바깥 인터넷과 통신이 가능해야한다. 그래서 Destination이 '0.0.0.0/0'일 때는 Target이 해당 VPC에 구성된 Internet Gateway로 설정해야 한다.

Private서브넷에 연결된 B테이블을 보자. Private서브넷이니까 외부와 통신을 하면 안 된다. 대신 서브넷이 속해있는 VPC안에서는 마음대로 통신이 가능하다. 그래서 A테이블과 동일하게 Destination이 '10.0.0.0/16(VPC CIDR)'일 때는 Target을 Local로 한다. 그럼 만약에 소프트웨어 업데이트나 설치를 위해 외부와 통신을 해야 한다면 어떻게 해야할까?

결론부터 얘기하면 Private서브넷은 Public서브넷에 설치되어 있는 NAT Gateway을 통해서 외부와 통신을 한다. 그래서 A테이블과는 달리 Private서브넷에서 Destination이 '0.0.0.0/0'이면 Target은 NAT Gateway으로 설정해야 한다. 그러면 그 뒤로 NAT Gateway가 알아서 외부와 통신할 것이다. Private서브넷에 있는 Resource들은 NAT Gateway를 통해 간접적으로 외부와 통신할 수 있다.

### 2021.01.28

~~~
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public_subnet_a"
  }
}
~~~
Public subnet을 구성할 때, `map_public_ip_on_launch = true` 설정을 해놓으면 해당 subnet에 ec2를 생성할 때마다 자동으로 public ip가 ec2인스턴스에 할당된다. 만약에 `map_public_ip_on_launch = true`가 없는 상태에서 subnet을 구성하고 그 subnet안에 ec2를 생성한다고 가정해보자. 그러면 콘솔에서 ec2를 생성할 때와 다르게 자동으로 public ip주소가 할당되지 않는다. 까먹기 좋으니까 잘 기억하고 있자.

인스턴스에 할당되어 있는 보안 그룹을 바꾸려고 했다. 그래서 새로운 보안 그룹을 생성하고 EC2에 새로운 보안 그룹으로 할당했다. 기존의 보안 그룹을 지우고 `terraform apply`를 했지만 아무런 오류 메세지도 없이 계속 기존의 보안 그룹을 삭제하려고 시도한다. 콘솔로 들어가서 확인해보니까 기존의 보안 그룹은 여러 곳에 묶여 있기 때문에 삭제가 불가능하다고 한다. 이런 경우에도 Terraform이 오류 메세지를 보낼 줄 알았는데,,, 내가 직접 생성이나 삭제 순서를 잘 고려해야겠다.

오늘은 어제 구성한 VPC에 EC2와 ALB를 올려봤다. 계속 한 tf파일에 resource들을 담고있는데 뭔가 쌈박한 방법으로 정리하는 방법이 있을 거 같다. 내일 찾아보자.

### 2021.01.30
오늘은 ALB에 Auto Scaling을 붙여볼 예정이다. ALB와 Auto Scaling 정책을 설립한다. Auto Scaling Group의 평균 CPU 활용률이 50%일 때 인스턴스를 늘리는 것으로 한다.

테스트는 아래와 같이 진행된다.
1. 우선 ALB을 통해 트래픽이 분산되는지 확인하자.
2. 현재 생성된 모든 인스턴스에 각각 들어가서 stress를 준다.
3. Auto Scaling이 적용되는지 확인.
4. 그리고 ALB을 통해 새로 생성된 인스턴스에도 트래픽이 가는지 확인한다.

계획
1. 새로운 인스턴스를 생성 v
2. 인스턴스에서 apache2를 설치하고 실행 v
3. 인스턴스를 중지하고 이미지 생성 및 실행 테스트 v
4. 이미지 기반으로 시작 템플릿 생성 v
5. 시작 템플릿 기반으로 오토스케일링 그룹 생성 v
6. 오토스케일링 테스트 v
7. ALB장착

`stress --cpu 1 --timeout 600`

테스트 결과
ALB에 Auto Scaling를 붙였을 때, 각 인스턴스에 stress를 주면 당연히 인스턴스의 수는 늘어났다. 그리고 ALB에 트래픽을 1초에 한 번씩 보내면 각 인슽턴스로 트래픽이 분산됐다. 그리고 ALB를 구성할 때는 Target Group만 만들고 따로 인스턴스는 따로 넣어주지는 않는다. Auto Scaling을 구성할 때 ALB를 구성하면 알아서 ALB에 딸린 Target Group에 이미지 기반으로 인스턴스가 생성된다.