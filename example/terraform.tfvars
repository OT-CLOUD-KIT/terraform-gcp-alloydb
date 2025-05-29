project_id = "nw-opstree-dev-landing-zone"

region = "us-central-1"

postgres_password = "Password"

network_name = "default"

clusters = {
  "primary-cluster" = {
    location     = "us-central1"
    network      = "default"
    is_secondary = false
  },
  "secondary-cluster" = {
    location             = "us-east1"
    network              = "default"
    is_secondary         = true
    primary_cluster_name = "primary-cluster"
    primary_location     = "us-central1"
  }
}

instances = {
  "primary-instance" = {
    cluster       = "primary-cluster"
    location      = "us-central1"
    instance_type = "PRIMARY"
    cpu_count     = 2
  },
  "readpool-instance" = {
    cluster              = "primary-cluster"
    location             = "us-central1"
    instance_type        = "READ_POOL"
    cpu_count            = 2
    read_pool_node_count = 1
  }
}
