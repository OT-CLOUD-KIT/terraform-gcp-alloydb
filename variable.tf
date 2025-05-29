variable "project_id" {
  type = string
}

variable "postgres_password" {
  type        = string
  description = "Password for the initial AlloyDB postgres user"
  sensitive   = true
}

variable "network_name" {
  type        = string
  description = "Name of the VPC network to peer with AlloyDB"
}

variable "clusters" {
  type = map(object({
    location             = string
    network              = string
    is_secondary         = optional(bool, false)
    primary_cluster_name = optional(string)
    primary_location     = optional(string)
  }))
}

variable "instances" {
  type = map(object({
    cluster              = string
    instance_type        = string
    location             = string
    cpu_count            = number
    read_pool_node_count = optional(number)
  }))
}