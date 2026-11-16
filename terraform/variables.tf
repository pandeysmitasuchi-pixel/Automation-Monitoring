variable "aws_region" {
  description = "AWS region required by the assignment"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  type        = string
  default     = "travelmemory-devops"
  description = "Prefix used in resource names and tags"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your current public IPv4 address in CIDR notation, e.g. 203.0.113.10/32. Do not use 0.0.0.0/0 for SSH."
  validation {
    condition     = can(cidrnetmask(var.my_ip_cidr)) && endswith(var.my_ip_cidr, "/32")
    error_message = "Set my_ip_cidr to your own public IPv4 address with a /32 mask."
  }
}

variable "public_key_path" {
  type        = string
  description = "Path to the SSH public key on the machine running Terraform"
  default     = "~/.ssh/travelmemory.pub"
}

variable "web_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Use at least 2 GiB RAM for the React production build"
}

variable "db_instance_type" {
  type        = string
  default     = "t3.small"
  description = "Adjust to your budget and assignment requirements"
}
