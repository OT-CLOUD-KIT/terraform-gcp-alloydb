output "primary_cluster_ids" {
  value = { for k, v in google_alloydb_cluster.primary : k => v.id }
}

output "secondary_cluster_ids" {
  value = { for k, v in google_alloydb_cluster.secondary : k => v.id }
}

output "instance_ids" {
  value = merge(
    { for k, v in google_alloydb_instance.main_instances : k => v.id },
    { for k, v in google_alloydb_instance.read_pool_instances : k => v.id }
  )
}

output "peering_connection" {
  value = google_service_networking_connection.private_vpc_connection.id
}