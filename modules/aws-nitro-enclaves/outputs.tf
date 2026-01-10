output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.bcl_nitro.id
}

output "instance_arn" {
  description = "The ARN of the EC2 instance"
  value       = aws_instance.bcl_nitro.arn
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.bcl_nitro.id
}

output "root_volume_id" {
  description = "The EBS volume ID of the root disk"
  value       = aws_instance.bcl_nitro.root_block_device[0].volume_id
}
