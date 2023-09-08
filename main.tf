locals {
  common_config = {
    zone_id = var.zone_id
  }

  records = flatten([
    for target_host, list_of_records in var.map_of_records : [
      for rec in list_of_records : merge(
        {
          ttl     = var.default_ttl
          value   = target_host
        }, rec
      )
    ]
  ])
}

variable "zone_id" {
  description = "Zone ID for the Cloudflare domain"
  type        = string
}

variable "default_ttl" {
  description = "Default Time to Live for DNS records"
  type        = number
  default     = 300
}

variable "map_of_records" {
  description = "Map of values to list of records with that value"
  type = map(list(object({
    name    = string
    proxied = bool
    ttl     = optional(number)
    type    = string
    priority = optional(number)
  })))
}

resource "cloudflare_record" "this" {
  for_each = { for rec in local.records : "${rec.name}-${rec.value}" => rec }

  name      = each.value.name
  value     = each.value.value
  type      = each.value.type != null ? each.value.type : "CNAME" # use type if specified, else default to CNAME
  zone_id   = local.common_config.zone_id
  ttl       = each.value.ttl
  proxied   = each.value.proxied
  priority  = each.value.priority

  # dynamic "priority" {
  #   for_each = each.value.priority != null ? [each.value.priority] : []
  #   content {
  #     priority = priority.value
  #   }
  # }
}
