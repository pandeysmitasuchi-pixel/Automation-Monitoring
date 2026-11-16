output "web_public_ip" {
  description = "Open the TravelMemory website at http://<this-ip> after Ansible deployment"
  value       = aws_instance.web.public_ip
}
output "web_private_ip" { value = aws_instance.web.private_ip }
output "db_private_ip"  { value = aws_instance.db.private_ip }
output "vpc_id"         { value = aws_vpc.main.id }
output "web_security_group_id" { value = aws_security_group.web.id }
output "db_security_group_id"  { value = aws_security_group.db.id }
