#!/usr/bin/env python3
"""Delete only four explicitly identified legacy synthetic checks.

Reads a Grafana Synthetic Monitoring API access token from SM_ACCESS_TOKEN.
Does not mutate anything unless --apply is supplied. Never prints the token.
Uses only Python's standard library.
"""

import argparse
import json
import os
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlsplit
from urllib.request import Request, urlopen

TARGET_HOSTS = {
    "pennsylvaniawmscog.com",
    "virginiawmscog.com",
    "iglesiadediossmmrd.org",
    "weloveuusa.org",
}
DEFAULT_BASE = "https://synthetic-monitoring-api-us-central2.grafana.net"


def api(method: str, path: str, base: str, token: str):
    req = Request(
        f"{base.rstrip('/')}{path}",
        headers={"Authorization": f"Bearer {token}", "Accept": "application/json"},
        method=method,
    )
    try:
        with urlopen(req, timeout=25) as res:
            payload = res.read()
            return json.loads(payload) if payload else {}
    except HTTPError as err:
        # Never include request authorization headers in exceptions or logs.
        raise RuntimeError(f"{method} {path} failed: HTTP {err.code}") from None
    except URLError as err:
        raise RuntimeError(f"Network error calling {path}: {err.reason}") from None


def list_checks(base: str, token: str) -> list:
    for endpoint in ("/api/v1/check/list", "/api/v1/check"):
        try:
            result = api("GET", endpoint, base, token)
            if isinstance(result, list):
                return result
            if isinstance(result, dict) and isinstance(result.get("checks"), list):
                return result["checks"]
            raise RuntimeError(f"Unexpected response from {endpoint}: expected a list")
        except RuntimeError as err:
            if "HTTP 404" not in str(err):
                raise
    raise RuntimeError("Synthetic Monitoring check-list endpoint not found")


def matching(check: dict) -> bool:
    target = check.get("target", "")
    if not isinstance(target, str):
        return False
    # Exact host match; never match an arbitrary subdomain or similarly named domain.
    parsed = urlsplit(target if "://" in target else f"https://{target}")
    return (parsed.hostname or "").lower() in TARGET_HOSTS


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Perform targeted deletions; without this, report only")
    args = parser.parse_args()
    token = os.getenv("SM_ACCESS_TOKEN", "").strip()
    base = os.getenv("SM_API_BASE", DEFAULT_BASE).strip()
    if not token:
        print("Set SM_ACCESS_TOKEN in your local shell. Never commit or paste it into chat.", file=sys.stderr)
        return 2
    try:
        checks = list_checks(base, token)
        selected = [check for check in checks if isinstance(check, dict) and matching(check)]
        print(f"Found {len(checks)} total Synthetic Monitoring checks; {len(selected)} legacy checks to remove.")
        for check in selected:
            print(f"  id={check.get('id')}, job={check.get('job')!r}, target={check.get('target')!r}")
        if not selected:
            print("No legacy checks remain; nothing to delete.")
            return 0
        if not args.apply:
            print("DRY RUN ONLY. Re-run with --apply to delete exactly the listed checks.")
            return 0
        for check in selected:
            check_id = str(check.get("id", ""))
            if not check_id.isdecimal():
                raise RuntimeError(f"Refusing deletion of check with invalid id: {check_id!r}")
            api("DELETE", f"/api/v1/check/delete/{quote(check_id)}", base, token)
            print(f"Deleted {check.get('target')!r} (id {check_id}).")
        remaining = [check for check in list_checks(base, token) if isinstance(check, dict) and matching(check)]
        if remaining:
            print(f"VERIFY FAILED: {len(remaining)} legacy checks remain.", file=sys.stderr)
            return 1
        print("VERIFIED: Zero legacy checks remain. New checks and other resources were untouched.")
        return 0
    except RuntimeError as err:
        print(f"ERROR: {err}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
