# Variables
variable "domain_names" {
  # default     = "saluteslim.me"
  type        = map(string)
  description = "Terraform sub-domain"
}
