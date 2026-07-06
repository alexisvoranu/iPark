output "instance_public_ip" {
  value       = aws_instance.devops_server.public_ip
  description = "The public IP address of the Jenkins server"
}