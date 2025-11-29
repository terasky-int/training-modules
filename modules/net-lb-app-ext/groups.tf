resource "google_compute_instance_group" "default" {
  for_each = var.group_configs
  project = (
    each.value.project_id == null
    ? var.project_id
    : each.value.project_id
  )
  zone        = each.value.zone
  name        = "${var.name}-${each.key}"
  description = var.description
  instances   = each.value.instances

  dynamic "named_port" {
    for_each = each.value.named_ports
    content {
      name = named_port.key
      port = named_port.value
    }
  }
}
