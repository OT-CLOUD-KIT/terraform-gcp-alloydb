resource "google_project_service" "alloydb_api" {
  service = "alloydb.googleapis.com"
}

resource "google_project_service" "service_networking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "alloydb-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "projects/${var.project_id}/global/networks/${var.network_name}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.project_id}/global/networks/${var.network_name}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]

  depends_on = [
    google_project_service.service_networking
  ]
}

resource "google_alloydb_cluster" "primary" {
  for_each = { for k, v in var.clusters : k => v if v.is_secondary == false }

  cluster_id = each.key
  location   = each.value.location

  network_config {
    network = "projects/${var.project_id}/global/networks/${var.network_name}"
  }

  initial_user {
    user     = "postgres"
    password = var.postgres_password
  }

  depends_on = [
    google_project_service.alloydb_api,
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_alloydb_cluster" "secondary" {
  for_each = { for k, v in var.clusters : k => v if v.is_secondary == true }

  cluster_id = each.key
  location   = each.value.location
  network_config {
    network = "projects/${var.project_id}/global/networks/${var.network_name}"
  }
  cluster_type = "SECONDARY"

  secondary_config {
    primary_cluster_name = "projects/${var.project_id}/locations/${each.value.primary_location}/clusters/${each.value.primary_cluster_name}"
  }

  depends_on = [
    google_alloydb_cluster.primary,
    google_alloydb_instance.main_instances
  ]
}

resource "google_alloydb_instance" "main_instances" {
  for_each = {
    for k, v in var.instances : k => v
    if v.instance_type != "READ_POOL"
  }

  instance_id   = each.key
  cluster       = "projects/${var.project_id}/locations/${each.value.location}/clusters/${each.value.cluster}"
  instance_type = each.value.instance_type

  machine_config {
    cpu_count = each.value.cpu_count
  }

  depends_on = [
    google_alloydb_cluster.primary,
  ]
}

resource "google_alloydb_instance" "read_pool_instances" {
  for_each = {
    for k, v in var.instances : k => v
    if v.instance_type == "READ_POOL"
  }

  instance_id   = each.key
  cluster       = "projects/${var.project_id}/locations/${each.value.location}/clusters/${each.value.cluster}"
  instance_type = "READ_POOL"

  machine_config {
    cpu_count = each.value.cpu_count
  }

  read_pool_config {
    node_count = each.value.read_pool_node_count
  }

  depends_on = [
    google_alloydb_instance.main_instances
  ]
}