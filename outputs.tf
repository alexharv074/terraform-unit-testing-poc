locals {
  this_id        = aws_instance.this[*].id
  this_public_ip = aws_instance.this[*].public_ip
}

output "id" {
  description = "List of IDs of instances"
  value       = local.this_id
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = local.this_public_ip
}
