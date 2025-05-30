# Terraform GCP Alloy-DB

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

This Terraform module provisions AlloyDB clusters and instances (PRIMARY, SECONDARY, and READ_POOL) on GCP with private VPC peering. It supports multiple clusters and dynamic instance creation based on input maps. The setup includes API enablement, IP allocation, VPC peering, and dependency-managed resource provisioning.

## ✅ Test Cases Verified

| Scenario                               | Status  | Notes                                                      |
|----------------------------------------|---------|------------------------------------------------------------|
| Primary Only                           | ✅ Valid | Basic setup with a single primary cluster                 |
| Primary + Read Pool                    | ✅ Valid | Read pool created under an existing primary cluster       |
| Read Pool without Primary              | ❌ Invalid | READ_POOL requires an existing PRIMARY instance           |
| Primary + Secondary + Read Pool        | ✅ Valid | Complete setup with replication and read scalability      |
| Multiple Read Pools, No Primary        | ❌ Invalid | READ_POOL requires a PRIMARY instance in the same cluster |


> ℹ️ **Note:** **`READ_POOL` instances can only be created under a cluster that already has a `PRIMARY` instance**.


## Architecture

<img width="600" length="800" alt="Terraform" src="https://github.com/user-attachments/assets/d77a586d-ae1d-46e3-843e-b76d9c36b368">

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_gcp"></a> [gcp](#provider\_gcp) | 5.0.0   |

## Usage

```hcl
module "alloydb" {
  source            = "./module"
  project_id        = var.project_id
  postgres_password = var.postgres_password
  network_name      = var.network_name
  clusters          = var.clusters
  instances         = var.instances
}

```

## Inputs

| Name | Description | Type | Default | Required | 
|------|-------------|:----:|---------|:--------:|
| **project_id**  | GCP Project ID                    | string         | n/a     |   yes    |
| **region**      | Region for the resources          |   string       | n/a     |   yes    |
| **postgres_password** | Password for the initial AlloyDB postgres user     | string (sensitive)| n/a |  yes |
| **network_name**| Name of the VPC network to peer with AlloyDB                 | string        | n/a |  yes |
| **clusters**    | Map of AlloyDB clusters, supports both primary and secondary | map(object()) | n/a |  yes |
| **instances**   | Map of AlloyDB instances with their type, cluster, and config| map(object()) | n/a |  yes |


## Outputs

| Name                     | Description                                                                |
|--------------------------|----------------------------------------------------------------------------|
| **primary_cluster_ids**  | Map of primary AlloyDB cluster IDs, keyed by cluster name                  |
| **secondary_cluster_ids**| Map of secondary AlloyDB cluster IDs, keyed by cluster name                |
| **instance_ids**         | Map of all AlloyDB instance IDs (both main and read pool), keyed by name   |
| **peering_connection**   | ID of the private VPC peering connection created for AlloyDB networking    |
