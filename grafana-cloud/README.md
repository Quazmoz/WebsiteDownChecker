# Grafana Cloud Synthetic Monitoring — Quazmoz production sites

This is the **remaining collection layer** for the existing Grafana Cloud dashboard and alerts. As of November 23, 2026, Grafana resources have already been created:

- [Production Websites dashboard](https://flyingpork15.grafana.net/d/quazmoz-websites)
- [17 website alert rules](https://flyingpork15.grafana.net/alerting/list) in folder `Quazmoz Production Apps`
- Contact point: `Quazmoz App Monitoring` → `quazmoz@vivaldi.net`
- Four pre-existing WMSCOG/related synthetic checks **remain active and need to be deleted** to reclaim Free tier capacity. The cleanup script below targets only those four. Their historical notification contact/policy do not consume synthetic-check executions.

**The seven HTTP synthetic checks are NOT live yet.** The linked Grafana MCP connection can create dashboard and rule resources but cannot access the separate Synthetic Monitoring API; datasource-proxy attempts returned HTTP 502. This folder allows one manual, idempotent Terraform apply once a Synthetic Monitoring API token is available. Do not call this production monitoring active until `probe_success` appears for these sites.

## Remove legacy checks to recover Free tier capacity (priority)

Four pre-existing checks (Pennsylvania, Virginia, Dominican Republic, and WeLoveU) still emit **30 probe results/hour each**, approximately **86,400 executions/month combined**. The connected Grafana MCP cannot reach the separate Synthetic Monitoring API for these checks; they have **not** been deleted automatically. You must do ONE of the following before enabling the faster Quazmoz website polling:

- **Simplest:** Open [Grafana Synthetics → Checks](https://flyingpork15.grafana.net/a/grafana-synthetic-monitoring-app/checks), find the four jobs, and delete each. Disabling immediately also stops executions, but deletion cleans up the configuration.
- **Repeatable cleanup (only those four hostnames):** use the checked-in standard-library-only Python script with a Synthetic Monitoring API access token. First preview, then apply, then verify:
  ```bash
  # Generate a Synthetic Monitoring token in Grafana Configuration → Access tokens.
  # Supply this locally. Never commit, log, or paste it into chat.
  export SM_ACCESS_TOKEN='TOKEN_FROM_GRAFANA'
  python3 grafana-cloud/remove_legacy_checks.py
  python3 grafana-cloud/remove_legacy_checks.py --apply
  unset SM_ACCESS_TOKEN
  ```

The script matches **exact hostnames**, lists check IDs and job names, requires explicit `--apply`, deletes matching checks through the documented API, then re-lists to verify none remain. It does not touch Quazmoz application checks.

After deletion, the synthetic execution forecast for the four legacy jobs falls from **86,400/month to zero new tests**, though historical consumption within the current billing period remains on the usage report.

The old `WMSCOG` contact point and root notification policy still exist. They don't generate probe executions and cannot be removed through this Grafana connection (API returned HTTP 403). After removing checks, optionally clean up the contact/policy in [Grafana Alerting → Notification policies](https://flyingpork15.grafana.net/alerting/routes) and [Contact points](https://flyingpork15.grafana.net/alerting/notifications), setting the default to `Quazmoz App Monitoring` first. Existing Quazmoz rules explicitly select their contact point.

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

Grafana already runs four legacy checks that emit roughly 30 samples/hour each, equivalent to **86,400 API test executions per 30-day month** if their schedule remains constant. Grafana Cloud's current Free tier includes 100,000 API test executions per month.

To avoid unexpected charges, the **default** in `main.tf` uses **20-minute polling for three critical websites** and **60-minute polling for four secondary websites**, one NorthVirginia public probe per check. This adds approximately **9,360 monthly executions**, or **95,760 total** combined with the four legacy checks, leaving a limited 4,240-execution buffer. Check your account's actual plan, existing SM usage, and allowance before applying. All checks use HTTP GET, HTTP 200 after redirects, and 5-second timeouts.

After verifying ALL FOUR legacy checks are deleted, use `terraform -chdir=grafana-cloud apply -var='fast_polling=true'`: this configures **5 minutes for critical sites** and **10 minutes for secondary sites**, consuming approximately **43,200 additional monthly executions**. After removal of all four legacy jobs, the projected new usage becomes **43,200/month** from your seven Quazmoz sites, under the **100,000/month** Free tier cap if there are no other API checks. Before legacy deletion, the same configuration would total around **129,600/month** and exceed the allowance.

The 3-minute outage alert pending time starts only after a failed check result. A 20-minute or 60-minute polling interval can therefore produce considerably longer real-world outage detection times. Increase frequency only after checking billing.

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
