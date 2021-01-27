# VPC, ALB, EC2, RDS with Terraform

### 목표 아키텍처
![스크린샷 2021-01-27 오전 3 28 34](https://user-images.githubusercontent.com/46708207/105888098-de1c1f80-604f-11eb-80c0-eb152be312b6.png)

### 2021.01.27

#### VPC > IGW > SUBNET(Multi-AZ) > EIP > NAT Gateway > Route Table

Route Table을 어떻게 구성하느냐에 따라서 public인지 private인지 결정난다. Public서브넷에 연결되어 있는 Route Table을 A라고 하고 Private서브넷에 연결되어 있는 Route Table을 B라고 하자.

우선 A테이블에서는 Destination이 '10.0.0.0/16'(VPC CIDR)일 때는 Target을 Local로 한다. 다시 말해서 VPC안에서 왔다리 갔다리 하겠다는 뜻이다. 그리고 Public서브넷이니까 바깥 인터넷과 통신이 가능해야한다. 그래서 Destination이 '0.0.0.0/0'일 때는 Target이 해당 VPC에 구성된 Internet Gateway로 설정해야 한다.

Private서브넷에 연결된 B테이블을 보자. Private서브넷이니까 외부와 통신을 하면 안 된다. 대신 서브넷이 속해있는 VPC안에서는 마음대로 통신이 가능하다. 그래서 A테이블과 동일하게 Destination이 '10.0.0.0/16(VPC CIDR)'일 때는 Target을 Local로 한다. 그럼 만약에 소프트웨어 업데이트나 설치를 위해 외부와 통신을 해야 한다면 어떻게 해야할까?

결론부터 얘기하면 Private서브넷은 Public서브넷에 설치되어 있는 NAT Gateway을 통해서 외부와 통신을 한다. 그래서 A테이블과는 달리 Private서브넷에서 Destination이 '0.0.0.0/0'이면 Target은 NAT Gateway으로 설정해야 한다. 그러면 그 뒤로 NAT Gateway가 알아서 외부와 통신할 것이다. Private서브넷에 있는 Resource들은 NAT Gateway를 통해 간접적으로 외부와 통신할 수 있다.