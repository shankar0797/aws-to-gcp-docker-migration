# Validation and Data Integrity

## 1. Purpose

Record the validation performed after migrating the Docker-based application from AWS EC2 to GCP Compute Engine.

## 2. Target environment

- GCP VM: aws-migration-target
- Zone: asia-south1-c
- Machine type: e2-micro
- Docker network: backend-network
- Public reverse-proxy endpoint: http://34.47.197.186:8081

## 3. Validation results

| Check | Result | Evidence |
|---|---|---|
| GCP VM state | RUNNING when inspected | command-outputs/05-gcp-vm-details.txt |
| Docker images | Six application images loaded, plus curl test image | command-outputs/06-gcp-docker-images.txt |
| Application containers | Five containers observed running | command-outputs/07-gcp-container-status.txt |
| Reverse-proxy configuration syntax | Passed | Captured terminal output |
| API-gateway configuration syntax | Passed | Captured terminal output |
| Public reverse-proxy health endpoint | HTTP 200 observed | Browser test and reverse-proxy logs |
| API-gateway user route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |
| API-gateway order route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |
| API-gateway payment route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |
| Reverse-proxy user route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |
| Reverse-proxy order route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |
| Reverse-proxy payment route | HTTP 200 | command-outputs/11-gcp-route-validation.txt |

## 4. Data-preservation findings

The source assessment found no Docker volumes and no mounted container volumes.

This does not prove that the application has no persistent data. Data could exist inside container writable layers, on the host filesystem, in an external database, or in another dependency.

The following items remain unverified:

- Whether the application writes important data locally.
- Whether an external database or storage service is used.
- Whether application data was included in the migration.
- Whether source and target data are equivalent.
- Whether any required database backup can be restored successfully.

Do not claim data integrity is verified until the data locations and expected contents are identified and compared.

## 5. Additional checks required before production

1. Identify all application data stores and external dependencies.
2. Record relevant source configuration and baseline application behavior.
3. Verify the transferred image archive with matching source and destination checksums.
4. Compare required application data against a known-good source baseline.
5. Test application behavior after container and VM restarts.
6. Confirm backup and restore procedures.
7. Confirm whether the forward proxy is required.
8. Review firewall exposure and configure HTTPS where appropriate.
9. Obtain application-owner approval.

## 6. Scope and limitations

The successful route tests demonstrate that the tested HTTP paths returned the expected service-specific responses on the GCP target.

They do not independently demonstrate:

- Persistent-data integrity.
- Zero-downtime migration.
- Production-scale performance.
- High availability across failure domains.
- Successful rollback.
- Complete security compliance.

The source containers were already stopped before this migration exercise. Therefore, this lab does not establish downtime reduction against a healthy source application.
