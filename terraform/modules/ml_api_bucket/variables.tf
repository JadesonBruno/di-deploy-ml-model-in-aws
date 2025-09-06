variable "project_name" {
  description = "Project name"
  type = string
  default = "deploy-ml-model"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type = string
  default = "dev"

  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be: dev, staging or prod."
  }
}
