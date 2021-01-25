resource "aws_alb" "koozzi_alb" {
  name               = "koozzi-alb"
  internal           = false
  subnets            = ["subnet-aad402c1", "subnet-00447e4c"]
  security_groups    = ["sg-03b15fd39b667c996"]
  load_balancer_type = "application"
  
  tags = {
    Name = "koozzi-alb"
  }
}

resource "aws_alb_target_group" "koozzi_alb_target" {
  name     = "koozzi-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-3c1bbe57"
}

resource "aws_alb_target_group_attachment" "target_attachment_1" {
  target_group_arn = "${aws_alb_target_group.koozzi_alb_target.arn}"
  target_id        = "i-0c28891d4570b9ce4"
  port             = 80
}

resource "aws_alb_target_group_attachment" "target_attachment_2" {
  target_group_arn = "${aws_alb_target_group.koozzi_alb_target.arn}"
  target_id        = "i-05a527a1c9f03e9f4"
  port             = 80
}

resource "aws_alb_listener" "koozzi-listener" {
  load_balancer_arn = aws_alb.koozzi_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.koozzi_alb_target.arn
  }
}