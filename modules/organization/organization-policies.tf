locals {
  factory_data_path_temp = pathexpand(coalesce(var.factories_config.org_policies, "-"))
  factory_data_raw_temp = merge([
    for f in try(fileset(local.factory_data_path_temp, "*.yaml"), []) :
    yamldecode(file("${local.factory_data_path_temp}/${f}"))
  ]...)
  # simulate applying defaults to data coming from yaml files
  factory_data_temp = {
    for k, v in local.factory_data_raw_temp :
    k => {
      inherit_from_parent = try(v.inherit_from_parent, null)
      reset               = try(v.reset, null)
      rules = [
        for r in try(v.rules, []) : {
          allow = can(r.allow) ? {
            all = try(r.allow.all, null)
            values = (
              can(r.allow.values)
              ? [for x in r.allow.values : templatestring(x, var.factories_config.context.org_policies)]
              : null
            )
          } : null
          deny = can(r.deny) ? {
            all = try(r.deny.all, null)
            values = (
              can(r.deny.values)
              ? [for x in r.deny.values : templatestring(x, var.factories_config.context.org_policies)]
              : null
            )
          } : null
          enforce = try(r.enforce, null)
          condition = {
            description = (
              can(r.condition.description)
              ? templatestring(r.condition.description, var.factories_config.context.org_policies)
              : null
            )
            expression = (
              can(r.condition.expression)
              ? templatestring(r.condition.expression, var.factories_config.context.org_policies)
              : null
            )
            location = (
              can(r.condition.location)
              ? templatestring(r.condition.location, var.factories_config.context.org_policies)
              : null
            )
            title = (
              can(r.condition.title)
              ? templatestring(r.condition.title, var.factories_config.context.org_policies)
              : null
            )
          }
          parameters = (
            can(r.parameters)
            ? templatestring(r.parameters, var.factories_config.context.org_policies)
            : null
          )
        }
      ]
    }
  }
  org_policies_temp = merge(local.factory_data_temp, var.org_policies)
  org_policies = {
    for k, v in local.org_policies_temp :
    k => merge(v, {
      is_boolean_policy = (
        alltrue([for r in v.rules : r.allow == null && r.deny == null])
      )
      has_values = (
        length(coalesce(try(v.allow.values, []), [])) > 0 ||
        length(coalesce(try(v.deny.values, []), [])) > 0
      )
      rules = [
        for r in v.rules :
        merge(r, {
          has_values = (
            length(coalesce(try(r.allow.values, []), [])) > 0 ||
            length(coalesce(try(r.deny.values, []), [])) > 0
          )
        })
      ]
    })
  }
}

resource "google_org_policy_policy" "default" {
  for_each = toset([
    for k, v in local.org_policies_temp : trimprefix(k, "dry_run:")
  ])
  name   = "${var.organization_id}/policies/${each.value}"
  parent = var.organization_id
  dynamic "spec" {
    for_each = lookup(local.org_policies, each.value, null) != null ? [local.org_policies[each.value]] : []
    iterator = spec
    content {
      inherit_from_parent = spec.value.inherit_from_parent
      reset               = spec.value.reset
      dynamic "rules" {
        for_each = spec.value.rules
        iterator = rule
        content {
          allow_all  = try(rule.value.allow.all, false) == true ? "TRUE" : null
          deny_all   = try(rule.value.deny.all, false) == true ? "TRUE" : null
          parameters = rule.value.parameters
          enforce = (
            spec.value.is_boolean_policy && rule.value.enforce != null
            ? upper(tostring(rule.value.enforce))
            : null
          )
          dynamic "condition" {
            for_each = rule.value.condition.expression != null ? [1] : []
            content {
              description = rule.value.condition.description
              expression  = rule.value.condition.expression
              location    = rule.value.condition.location
              title       = rule.value.condition.title
            }
          }
          dynamic "values" {
            for_each = rule.value.has_values ? [1] : []
            content {
              allowed_values = try(rule.value.allow.values, null)
              denied_values  = try(rule.value.deny.values, null)
            }
          }
        }
      }
    }
  }

  dynamic "dry_run_spec" {
    for_each = lookup(local.org_policies, "dry_run:${each.value}", null) != null ? [local.org_policies["dry_run:${each.value}"]] : []
    iterator = spec
    content {
      inherit_from_parent = spec.value.inherit_from_parent
      reset               = spec.value.reset
      dynamic "rules" {
        for_each = spec.value.rules
        iterator = rule
        content {
          allow_all  = try(rule.value.allow.all, false) == true ? "TRUE" : null
          deny_all   = try(rule.value.deny.all, false) == true ? "TRUE" : null
          parameters = rule.value.parameters
          enforce = (
            spec.value.is_boolean_policy && rule.value.enforce != null
            ? upper(tostring(rule.value.enforce))
            : null
          )
          dynamic "condition" {
            for_each = rule.value.condition.expression != null ? [1] : []
            content {
              description = rule.value.condition.description
              expression  = rule.value.condition.expression
              location    = rule.value.condition.location
              title       = rule.value.condition.title
            }
          }
          dynamic "values" {
            for_each = rule.value.has_values ? [1] : []
            content {
              allowed_values = try(rule.value.allow.values, null)
              denied_values  = try(rule.value.deny.values, null)
            }
          }
        }
      }
    }
  }

import {
  to = google_org_policy_policy.default
  id = "${var.organization_id}/policies/${each.value}"
}
  depends_on = [
    google_organization_iam_binding.authoritative,
    google_organization_iam_binding.bindings,
    google_organization_iam_member.bindings,
    google_organization_iam_custom_role.roles,
    google_org_policy_custom_constraint.constraint,
    google_tags_tag_key.default,
    google_tags_tag_value.default,
  ]
}
