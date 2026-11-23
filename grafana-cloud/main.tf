terraform {
  required_version = ">= 1.5.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.0"
    }
  }
}

variable "fast_polling" {
  description = "Opt-in to 5-minute critical / 10-minute secondary checks; increases usage and may exceed Free tier limits."
  type        = bool
  default     = false
}

variable "sm_access_token" {
  description = "Grafana Cloud Synthetic Monitoring access token; never commit this token."
  type        = string
  sensitive   = true
}

provider "grafana" {
  sm_url          = "https://synthetic-monitoring-api-us-central2.grafana.net"
  sm_access_token = var.sm_access_token
}

# The probe is confirmed present in existing Grafana synthetic metrics.
data "grafana_synthetic_monitoring_probes" "available" {}

locals {
  # Budget-safe defaults account for four existing 2-minute probe checks (~86,400/month).
  # 3 critical sites: 20m budget / 5m fast; 4 secondary sites: 60m budget / 10m fast.
  websites = {
    consultant     = { url = "https://consultant.quinnfavo.com", budget_frequency_ms = 1200000, fast_frequency_ms = 300000 }
    minddock       = { url = "https://minddock.quinnfavo.com", budget_frequency_ms = 1200000, fast_frequency_ms = 300000 }
    petcaredesk    = { url = "https://petcaredesk.quinnfavo.com", budget_frequency_ms = 1200000, fast_frequency_ms = 300000 }
    devopstoolkit  = { url = "https://devopstoolkit.quinnfavo.com", budget_frequency_ms = 3600000, fast_frequency_ms = 600000 }
    profile        = { url = "https://profile.quinnfavo.com", budget_frequency_ms = 3600000, fast_frequency_ms = 600000 }
    ai             = { url = "https://ai.quinnfavo.com", budget_frequency_ms = 3600000, fast_frequency_ms = 600000 }
    main           = { url = "https://quinnfavo.com", budget_frequency_ms = 3600000, fast_frequency_ms = 600000 }
  }
}

resource "grafana_synthetic_monitoring_check" "website" {
  for_each = local.websites

  job       = each.key
  target    = each.value.url
  enabled   = true
  frequency = var.fast_polling ? each.value.fast_frequency_ms : each.value.budget_frequency_ms
  timeout   = 5000

  probes = [
    data.grafana_synthetic_monitoring_probes.available.probes.NorthVirginia,
  ]

  labels = {
    monitoring_owner = "quazmoz"
    environment      = "production"
  }

  settings {
    http {
      method             = "GET"
      ip_version         = "V4"
      valid_status_codes = [200]
    }
  }
}

output "checks" {
  description = "Configured production HTTP uptime check IDs."
  value       = { for key, check in grafana_synthetic_monitoring_check.website : key => check.id }
}
