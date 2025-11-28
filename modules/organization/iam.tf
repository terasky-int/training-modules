locals {
  custom_roles_path_temp = pathexpand(coalesce(var.factories_config.custom_roles, "-"))
  custom_roles_temp = {
    for f in try(fileset(local.custom_roles_path_temp, "*.yaml"), []) :
    replace(f, ".yaml", "") => yamldecode(
      file("${local.custom_roles_path_temp}/${f}")
    )
  }
  iam_principal_roles_temp = distinct(flatten(values(var.iam_by_principals)))
  iam_principals_temp = {
    for r in local.iam_principal_roles_temp : r => [
      for k, v in var.iam_by_principals :
      k if try(index(v, r), null) != null
    ]
  }
  custom_roles = merge(
    {
      for k, v in local.custom_roles_temp : k => {
        name        = lookup(v, "name", k)
        permissions = v["includedPermissions"]
      }
    },
    {
      for k, v in var.custom_roles : k => {
        name        = k
        permissions = v
      }
    }
  )
  iam = {
    for role in distinct(concat(keys(var.iam), keys(local.iam_principals_temp))) :
    role => concat(
      try(var.iam[role], []),
      try(local.iam_principals_temp[role], [])
    )
  }
  iam_bindings_additive = merge(
    var.iam_bindings_additive,
    [
      for principal, roles in var.iam_by_principals_additive : {
        for role in roles :
        "iam-bpa:${principal}-${role}" => {
          member    = principal
          role      = role
          condition = null
        }
      }
    ]...
  )
}

# we use a different key for custom roles to allow referring to the role alias
# in Terraform, while still being able to define unique role names

check "custom_roles" {
  assert {
    condition = (
      length(local.custom_roles) == length({
        for k, v in local.custom_roles : v.name => null
      })
    )
    error_message = "Duplicate role name in custom roles."
  }
}

resource "google_organization_iam_custom_role" "roles" {
  for_each    = local.custom_roles
  org_id      = local.organization_id_numeric
  role_id     = each.value.name
  title       = "Custom role ${each.value.name}"
  description = "Terraform-managed."
  permissions = each.value.permissions
}

resource "google_organization_iam_binding" "authoritative" {
  for_each = local.iam
  org_id   = local.organization_id_numeric
  role     = each.key
  members  = each.value
  # ensuring that custom role exists is left to the caller, by leveraging custom_role_id output
}

resource "google_organization_iam_binding" "bindings" {
  for_each = var.iam_bindings
  org_id   = local.organization_id_numeric
  role     = each.value.role
  members  = each.value.members
  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
  # ensuring that custom role exists is left to the caller, by leveraging custom_role_id output
}

resource "google_organization_iam_member" "bindings" {
  for_each = local.iam_bindings_additive
  org_id   = local.organization_id_numeric
  role     = each.value.role
  member   = each.value.member
  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [""]
    content {
      expression  = each.value.condition.expression
      title       = each.value.condition.title
      description = each.value.condition.description
    }
  }
  # ensuring that custom role exists is left to the caller, by leveraging custom_role_id output
}

data "google_iam_role" "roleinfo" {
  for_each = toset(flatten([for k, v in var.dynamic_custom_roles : v.parents_roles]))
  name     = each.key
}

locals {
  dynamic_permissions = {
    for role_key, role_obj in var.dynamic_custom_roles :
    role_key => setsubtract(
      toset(flatten([
        for parent in role_obj.parents_roles :
        data.google_iam_role.roleinfo[parent].included_permissions
      ])),
      role_obj.exclude_permissions
    )
  }
  max_permissions_per_role = 1000
  dynamic_permission_chunks = {
    for chunk in flatten([
      for role_key, permissions in local.dynamic_permissions : [
        for i, subchunk in chunklist(sort(tolist(permissions)), local.max_permissions_per_role) : {
          key = "${role_key}_part${i + 1}"
          value = {
            role_id     = role_key
            part_number = i + 1
            permissions = subchunk
          }
        }
      ]
    ]) : chunk.key => chunk.value
  }
  dynamic_role_memberships = flatten([
    for chunk_key, chunk in local.dynamic_permission_chunks : [
      for member in coalesce(var.dynamic_custom_roles[chunk.role_id].attached_to, []) : {
        role_key    = chunk.role_id
        part_number = chunk.part_number
        member      = member
      }
    ]
  ])
}


resource "google_organization_iam_custom_role" "dynamic_custom_roles" {
  for_each    = local.dynamic_permission_chunks
  role_id     = "${each.value.role_id}${each.value.part_number}"
  org_id      = local.organization_id_numeric
  title       = "${each.value.role_id} (part ${each.value.part_number})"
  description = "Auto-chunked role for ${each.value.role_id}"
  stage       = "GA"

  permissions = each.value.permissions
}

resource "google_organization_iam_member" "dynamic_custom_roles" {
  for_each = {
    for rm in local.dynamic_role_memberships :
    "${rm.role_key}_part${rm.part_number}_${replace(rm.member, "[:@./]", "_")}" => rm
  }

  org_id = local.organization_id_numeric

  role   = "organizations/${local.organization_id_numeric}/roles/${each.value.role_key}${each.value.part_number}"
  member = each.value.member
  depends_on = [
    google_organization_iam_binding.authoritative,
    google_organization_iam_binding.bindings,
    google_organization_iam_custom_role.roles,
    google_organization_iam_member.bindings,
  ]

}
