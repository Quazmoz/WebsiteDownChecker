# Grafana Cloud Synthetic Monitoring — Quazmoz production sites

This is the **remaining collection layer** for the existing Grafana Cloud dashboard and alerts. As of November 23, 2026, Grafana resources have already been created:

- [Production Websites dashboard](https://flyingpork15.grafana.net/d/quazmoz-websites)
- [17 website alert rules](https://flyingpork15.grafana.net/alerting/list) in folder `Quazmoz Production Apps`
- Contact point: `Quazmoz App Monitoring` → `quazmoz@vivaldi.net`
- Existing WMSCOG notification routing and checks are **not** modified.

**The seven HTTP synthetic checks are NOT live yet.** The linked Grafana MCP connection can create dashboard and rule resources but cannot access the separate Synthetic Monitoring API; datasource-proxy attempts returned HTTP 502. This folder allows one manual, idempotent Terraform apply once a Synthetic Monitoring API token is available. Do not call this production monitoring active until `probe_success` appears for these sites.

## Activate the checks

1. Open [Grafana Synthetics Configuration](https://flyingpork15.grafana.net/a/grafana-synthetic-monitoring-app/config) → **Access tokens**; generate a Synthetic Monitoring token. This token has broad Synthetic Monitoring permissions; do not paste it into GitHub, commits, logs, or chat.
2. On a trusted workstation, clone this repository. Set the token as an environment variable:
   ```bash
   export TF_VAR_sm_access_token='YOUR_SYNTHETIC_MONITORING_TOKEN'
   terraform -chdir=grafana-cloud init
   terraform -chdir=grafana-cloud plan
   terraform -chdir=grafana-cloud apply
   ```
3. Confirm the new checks at [Grafana Synthetics → Checks](https://flyingpork15.grafana.net/a/grafana-synthetic-monitoring-app/checks). Verify their instances match the full HTTPS URLs here, **without a path**.
4. Open the [dashboard](https://flyingpork15.grafana.net/d/quazmoz-websites) and verify `probe_success{instance=~"https://(.*[.])?quinnfavo[.]com/?"}` returns seven target series.
5. Under [Alert rules](https://flyingpork15.grafana.net/alerting/list), check that all 17 rules have `Quazmoz App Monitoring` as their **direct contact point**, and test notification delivery through the contact point UI.
6. Keep the local Terraform state in a secure backend; never commit `terraform.tfstate` or local `.tfvars` files. If checks have already been created manually in Grafana, **import them first**, or Terraform will create duplicates.

## Frequency, alerts, and cost

Three higher-priority services use a 5-minute interval. Four less-critical sites use a 10-minute interval. All checks use one NorthVirginia public probe, HTTP GET, valid HTTP 200 after redirects, and a 5-second timeout. These checks need about **43,200 API test executions per 30-day month**, assuming each run lasts less than one minute. This **does not include your four pre-existing synthetic checks** and other sources of usage. The current Grafana Cloud Free tier includes 100k API test executions monthly; check your plan and consumption before applying. A 3-minute alert pending period is *additional* to the check polling interval, so actual time-to-detection may exceed 3 minutes.

### Existing rules (no duplicate Terraform rules created)

- 7× website-down: failure sustained for 3 minutes, critical
- 7× TLS cert expiring in fewer than 14 days: warning
- 3× response time over 3 seconds for 5 minutes: warning (Consulting, MindDock, PetCare Desk)
- All rules intentionally use `noDataState = OK` until the collectors are enabled. Once collection is operational, add separate no-data/heartbeat alerts so a silently stopped probe does not go unnoticed.

## Supabase next phase

The two Supabase projects `efspxwixortusvrsdohv` (**Google Play backend**) and `mgsqlozxgwskpvttnlzu` (**Quazmoz's Project**) have healthy backend status, but **their PostgreSQL metrics are not yet ingested by Grafana**. Use Supabase's official [one-click Grafana Cloud integration](https://supabase.com/docs/guides/observability/metrics/grafana-cloud) separately for each project, configuring the required Secret API keys in the Grafana/Supabase UI. Never commit project service-role/secret keys. Then verify `pg_*` metrics arrive before configuring database alerts.

The backend includes JetLag weather/geocode, WristExposure weather, AdHocKit account/billing and website payment/email functions. Avoid unauthenticated checks of purchase verification or account deletion functions; they need safe, authenticated health endpoints or internal telemetry.

## References

- [Grafana Synthetic Monitoring as code](https://grafana.com/docs/grafana-cloud/observe-and-act/testing/synthetic-monitoring/set-up/provision-synthetic-monitoring-resources/)
- [Terraform check resource](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/synthetic_monitoring_check)
- [Grafana pricing](https://grafana.com/docs/grafana-cloud/platform/pricing-and-usage/synthetic-monitoring/)
