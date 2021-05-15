# Application Load Balancer

resource "aws_alb" "public_alb" {
  name               = "public-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_c.id
  ]

  security_groups = [
    aws_security_group.alb_public_security_group.id
  ]

  tags = {
    "Name" = "public_alb"
  }
}

resource "aws_alb_target_group" "public_alb_target" {
  name     = "public-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_alb_target_group_attachment" "target_attachment_1" {
  target_group_arn = "${aws_alb_target_group.public_alb_target.arn}"
  target_id        = aws_instance.public_a.id 
  port             = 80
}

resource "aws_alb_target_group_attachment" "target_attachment_2" {
  target_group_arn = "${aws_alb_target_group.public_alb_target.arn}"
  target_id        = aws_instance.public_c.id 
  port             = 80
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.public_alb_target.arn
  }
}