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