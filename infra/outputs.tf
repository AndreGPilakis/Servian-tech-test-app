output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
output "lb_endpoint" {
  value = aws_lb.tech_test_app.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_user" {
  value = aws_db_instance.default.username
}

output "db_pass" {
  sensitive = true
  value     = aws_db_instance.default.password
}
