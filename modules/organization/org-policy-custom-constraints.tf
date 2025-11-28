locals {
  custom_constraints_factory_path_temp = pathexpand(coalesce(var.factories_config.org_policy_custom_constraints, "-"))
  custom_constraints_factory_data_raw_temp = merge([
    for f in try(fileset(local.custom_constraints_factory_path_temp, "*.yaml"), []) :
    yamldecode(file("${local.custom_constraints_factory_path_temp}/${f}"))
  ]...)
  custom_constraints_temp_factory_data = {
    for k, v in local.custom_constraints_factory_data_raw_temp :
    k => {
      display_name   = try(v.display_name, null)
      description    = try(v.description, null)
      action_type    = v.action_type
      condition      = v.condition
      method_types   = v.method_types
      resource_types = v.resource_types
    }
  }
  custom_constraints_temp = merge(
    local.custom_constraints_temp_factory_data,
    var.org_policy_custom_constraints
  )
  custom_constraints = {
    for k, v in local.custom_constraints_temp :
    k => merge(v, {
      name   = k
      parent = var.organization_id
    })
  }
}

resource "google_org_policy_custom_constraint" "constraint" {
  provider = google-beta

  for_each       = local.custom_constraints
  name           = each.value.name
  parent         = each.value.parent
  display_name   = each.value.display_name
  description    = each.value.description
  action_type    = each.value.action_type
  condition      = each.value.condition
  method_types   = each.value.method_types
  resource_types = each.value.resource_types
}
