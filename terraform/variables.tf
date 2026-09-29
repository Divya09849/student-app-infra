variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "student-gitops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition = contains(
      ["dev", "uat", "prod"],
      var.environment
    )

    error_message = "Environment must be dev, uat, or prod."
  }
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet configuration"

  type = map(object({
    cidr     = string
    az_index = number
  }))

  default = {
    public-a = {
      cidr     = "10.20.1.0/24"
      az_index = 0
    }

    public-b = {
      cidr     = "10.20.2.0/24"
      az_index = 1
    }
  }
}

variable "private_subnets" {
  description = "Private subnet configuration"

  type = map(object({
    cidr     = string
    az_index = number
  }))

  default = {
    private-a = {
      cidr     = "10.20.11.0/24"
      az_index = 0
    }

    private-b = {
      cidr     = "10.20.12.0/24"
      az_index = 1
    }
  }
}

variable "cluster_version" {
  description = "Amazon EKS Kubernetes version"
  type        = string
  default     = "1.36"
}

variable "cluster_public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS public API endpoint"
  type        = list(string)

  validation {
    condition = alltrue([
      for cidr in var.cluster_public_access_cidrs :
      can(cidrhost(cidr, 0))
    ])

    error_message = "All values must be valid CIDR blocks."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)

  default = [
    "t3.medium"
  ]
}

variable "node_desired_size" {
  description = "Desired EKS worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum EKS worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum EKS worker nodes"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "EKS worker node disk size in GiB"
  type        = number
  default     = 30
}