# ---------------------------------------------------------------------------------------------------------------------
# Naming
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
  default     = "broken-flask"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# Existing resources
# ---------------------------------------------------------------------------------------------------------------------
variable "domain_name" {
  type        = string
  description = "The domain name to use for the Route53 hosted zone"
  default     = "brokenlol.com"
}

variable "subdomain" {
  type        = string
  description = "The subdomain to use for the Route53 hosted zone"
  default     = "flask"
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------------------------------------------------
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR value"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}


variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}