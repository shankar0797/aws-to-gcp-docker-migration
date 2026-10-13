# AWS EC2 to GCP Compute Engine Migration

A hands-on cloud migration project demonstrating how to migrate a Docker-based application from an AWS EC2 instance to a Google Cloud Platform (GCP) Compute Engine VM.

## Project Overview

The source application consisted of multiple Docker services running on AWS EC2. The available Docker images were transferred to GCP, loaded into Docker, and deployed on a Compute Engine VM.

The target deployment was validated using HTTP health checks and application route tests.

**Project status:** Lab migration completed; production readiness checks remain open.

## Architecture

### Source Environment — AWS

- Compute: Amazon EC2
- Operating system: Amazon Linux 2023
- Container runtime: Docker
- Application: Reverse proxy, API gateway, user service, order service, and payment service

### Target Environment — GCP

- Compute: Google Compute Engine
- Region: Mumbai (`asia-south1`)
- Zone: `asia-south1-c`
- Machine type: `e2-micro`
- Container runtime: Docker
- Docker network: `backend-network`
- Reverse proxy: HTTP port 8081
- API gateway: HTTP port 8080 internally

## High-Level Request Flow

```text
Client
  |
  v
GCP Compute Engine VM
  |
  v
Reverse Proxy :8081
  |
  v
API Gateway :8080
  |
  +----> User Service :8001
  |
  +----> Order Service :8002
  |
  +----> Payment Service :8003
```

The service ports above describe the configured application routing. The reverse proxy and API gateway expose the application routes tested during this lab.

## Migration Activities

1. Assessed the source EC2 environment and existing Docker containers.
2. Reviewed available Docker images and searched for Docker volumes and deployment configuration.
3. Transferred the application image archive to the GCP environment.
4. Installed and verified Docker on the Compute Engine VM.
5. Loaded the Docker images and created the application Docker network.
6. Deployed the reverse proxy, API gateway, and application services.
7. Configured the GCP firewall rule and VM network tag for external testing.
8. Validated health endpoints and user, order, and payment routes.
9. Documented production readiness, security considerations, and rollback limitations.

## Validation Results

The following application routes returned HTTP 200 with their expected service-specific success responses:

| Test | Result |
|---|---|
| API gateway `/users` | Passed |
| API gateway `/orders` | Passed |
| API gateway `/payments` | Passed |
| Reverse proxy `/users` | Passed |
| Reverse proxy `/orders` | Passed |
| Reverse proxy `/payments` | Passed |
| Public reverse-proxy health endpoint | HTTP 200 observed |

See `evidence/command-outputs/11-gcp-route-validation.txt` for route validation results.

## Repository Structure

```text
architecture/     Architecture and request-flow documentation
docs/             Migration, security, rollback, and validation guides
scripts/          Reusable inventory and validation scripts
troubleshooting/  Troubleshooting case studies
cheatsheets/      AWS, GCP, and Docker command references
evidence/         Captured command outputs and evidence index
```

## Important Limitations

- The source application containers were already stopped before this migration exercise.
- No Docker volumes were found during the source assessment, but this alone does not prove that the application has no persistent data.
- Persistent-data integrity and external dependencies have not been fully verified.
- The lab does not demonstrate zero-downtime migration, production-scale capacity, high availability, or a tested rollback.
- The public HTTP endpoint and firewall configuration are for lab validation, not production security.
- The forward-proxy image was available, but its requirement has not been established.

## Production Readiness

Before production cutover, confirm:

- Persistent-data locations, backups, and data integrity.
- Required application dependencies and configuration.
- Source and destination image checksums.
- HTTPS and restricted network access.
- Monitoring, alerting, and recovery procedures.
- Capacity, availability, and rollback testing.
- Application-owner approval.

See `docs/production-checklist.md` for the detailed checklist.

## Skills Demonstrated

- AWS EC2 and GCP Compute Engine
- Docker image migration and container deployment
- Docker networking
- Reverse proxy and API gateway routing
- GCP firewall rules and network tags
- Linux-based troubleshooting
- HTTP health checks and application validation
- Migration documentation, evidence collection, and rollback planning

## Disclaimer

This is a learning and portfolio project. Validation results apply to the tested lab environment and should not be interpreted as proof of production readiness.
