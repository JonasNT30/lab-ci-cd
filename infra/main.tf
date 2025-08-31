resource "ecs_cluster_name" "this" {
  name = format("%s-cluster", var.cluster_name)

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}