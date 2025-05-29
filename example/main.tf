module "alloydb" {
  source            = "./module"
  project_id        = var.project_id
  postgres_password = var.postgres_password
  network_name      = var.network_name
  clusters          = var.clusters
  instances         = var.instances
}