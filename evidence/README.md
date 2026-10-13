# Evidence Register

This directory contains genuine evidence captured from the AWS-to-GCP migration lab.

## Evidence rules

- Capture screenshots directly from the real AWS, GCP, terminal, or browser session.
- Save command output from actual commands; redact secrets and sensitive identifiers where appropriate.
- Never create fake screenshots or label expected output as actual results.
- Mark an item complete only after the evidence file exists and has been reviewed.
- Record limitations: a successful health endpoint does not prove every application route or data set is correct.
- Do not commit credentials, private keys, access tokens, or sensitive configuration.

## Numbered evidence checklist

| ID | Evidence | Suggested filename | What it proves | Status |
|---|---|---|---|---|
| E01 | AWS source VM details | `command-outputs/01-aws-source-details.txt` | Source instance and environment details were inspected | Pending |
| E02 | Source Docker inventory | `command-outputs/02-aws-docker-inventory.txt` | Source images, containers, ports, networks, and mounts were inspected | Pending |
| E03 | Source application configuration | `command-outputs/03-source-config-review.txt` | Relevant container configuration and proxy routes were reviewed | Pending |
| E04 | Docker image transfer integrity | `command-outputs/04-image-transfer-checks.txt` | Transfer checksums match, if matching checksum records are available | Pending |
| E05 | GCP target VM details | `command-outputs/05-gcp-vm-details.txt` | Target VM, zone, external IP, and network configuration | Pending |
| E06 | Docker images on GCP | `command-outputs/06-gcp-docker-images.txt` | Required Docker images are present on the target | Pending |
| E07 | GCP container status | `command-outputs/07-gcp-container-status.txt` | Current container states and port mappings | Pending |
| E08 | Internal health checks | `command-outputs/08-internal-health-checks.txt` | Internal reverse-proxy and API-gateway health responses | Pending |
| E09 | Firewall rule and network tag | `command-outputs/09-gcp-firewall-tag.txt` | Ingress rule and target VM tag configuration | Pending |
| E10 | Public reverse-proxy health | `screenshots/06-public-reverse-proxy-health.png` | Browser successfully reached the reverse-proxy health endpoint | Captured in conversation; local file not yet verified |
| E11 | Application route tests | `command-outputs/11-application-route-tests.txt` | Results of user, order, and payment route tests | Pending |
| E12 | Container logs | `command-outputs/12-container-logs.txt` | Runtime logs reviewed for application errors | Pending |
| E13 | Data-integrity assessment | `command-outputs/13-data-integrity-review.txt` | Required persistent data and dependencies were identified and validated | Pending |
| E14 | Rollback readiness | `command-outputs/14-rollback-readiness.txt` | Source recovery and rollback prerequisites were assessed | Pending |
| E15 | Cleanup verification | `command-outputs/15-cleanup-review.txt` | Unneeded billable resources and retained resources were reviewed | Pending |

## Known validation limitation

The public reverse-proxy health endpoint has returned:

`Reverse Proxy is healthy`

This proves that the public endpoint responded at the time of the screenshot. It does not prove that all backend routes, business operations, data integrity, high availability, or rollback have been validated.

The source containers were stopped before migration. Confirm source recovery before treating the original VM as a working rollback target.

## Evidence naming convention

Use numbered filenames so evidence remains easy to map to project phases. Keep original screenshots intact; redact sensitive details only in a separate copy when necessary.

## Current project status

- Public reverse-proxy health: verified.
- Full application functionality: pending.
- Data integrity: pending.
- Production readiness: not established.
