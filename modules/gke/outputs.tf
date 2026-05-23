output "cluster_name"     { value = google_container_cluster.main.name }
output "cluster_endpoint" { value = google_container_cluster.main.endpoint }
output "cluster_version"  { value = google_container_cluster.main.master_version }
output "workload_pool"    { value = google_container_cluster.main.workload_identity_config[0].workload_pool }
