locals {
  organization_id_numeric = split("/", var.organization_id)[1]
}

resource "google_essential_contacts_contact" "contact" {
  provider                            = google-beta
  for_each                            = var.contacts
  parent                              = var.organization_id
  email                               = each.key
  language_tag                        = "en"
  notification_category_subscriptions = each.value
  depends_on = [
    google_organization_iam_binding.authoritative,
    google_organization_iam_binding.bindings,
    google_organization_iam_member.bindings
  ]
}


resource "google_compute_firewall_policy_association" "default" {
  count             = var.firewall_policy == null ? 0 : 1
  attachment_target = var.organization_id
  name              = var.firewall_policy.name
  firewall_policy   = var.firewall_policy.policy
}

resource "google_iam_deny_policy" "deny" {
  for_each = var.deny_policies
  parent       = urlencode("cloudresourcemanager.googleapis.com/${each.value.parent}")
  name         = each.value.name
  display_name = each.value.display_name

  dynamic "rules" {
    for_each = each.value.rules
    content {
      deny_rule {
        denied_principals  = rules.value.denied_principals
        denied_permissions = rules.value.denied_permissions

        # optional blocks
        exception_principals  = lookup(rules.value, "exception_principals", null)
        exception_permissions = lookup(rules.value, "exception_permissions", null)

        # condition
        dynamic "denial_condition" {
          for_each = can(regex(".*", lookup(rules.value, "denial_condition", {}))) && contains(keys(rules.value), "denial_condition") ? [rules.value.denial_condition] : []
          content {
            title       = denial_condition.value.title
            description = lookup(denial_condition.value, "description", null)
            expression  = denial_condition.value.expression
          }
        }
      }
    }
  }
}
