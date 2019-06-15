locals {
  this_id     = compact(coalescelist(aws_instance.this[*].id, aws_instance.this_t2[*].id, [""]))
  this_public_ip = compact(coalescelist(aws_instance.this[*].public_ip, aws_instance.this_t2[*].public_ip, [""]))
  this_credit_specification = flatten(aws_instance.this_t2[*].credit_specification)
}

output "id" {
  description = "List of IDs of instances"
  value       = local.this_id
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = local.this_public_ip
}

output "credit_specification" {
  description = "List of credit specification of instances"
  value       = local.this_credit_specification
}
