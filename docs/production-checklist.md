# Production Readiness Checklist

## 1. Purpose

Use this checklist to assess whether the Docker application migrated from AWS EC2 to GCP Compute Engine is ready for production cutover.

A successful lab test does not automatically mean the application is production-ready.

## 2. Infrastructure

- [x] GCP Compute Engine VM created.
- [x] VM confirmed in RUNNING state during validation.
- [x] Docker installed on the target VM.
- [x] Application Docker images loaded.
- [ ] Confirm CPU, memory, and disk capacity against application requirements.
- [ ] Configure production-appropriate availability and recovery.
- [ ] Confirm required resources and dependencies are documented.

## 3. Application Deployment

- [x] Reverse proxy deployed.
- [x] API gateway deployed.
- [x] User service deployed.
- [x] Order service deployed.
- [x] Payment service deployed.
- [ ] Confirm whether the forward proxy is required.
- [x] Reverse-proxy and API-gateway configuration syntax checked.
- [x] User, order, and payment routes tested successfully.
- [ ] Validate all required application functions with the application owner.
- [ ] Test behavior after VM reboot and container restart.
- [ ] Confirm container logs, health checks, and restart behavior.

## 4. Networking and Security

- [x] Public reverse-proxy endpoint tested over HTTP.
- [x] Firewall rule and VM network tag configured for port 8081.
- [ ] Restrict public ingress to approved sources or an appropriate production entry point.
- [ ] Configure HTTPS and certificate management.
- [ ] Review SSH access and administrative permissions.
- [ ] Verify IAM permissions follow least privilege.
- [ ] Review container privileges, secrets, and image vulnerabilities.
- [ ] Confirm internal services are not unnecessarily exposed.

## 5. Data and Dependencies

- [x] Source assessment found no Docker volumes.
- [ ] Identify all persistent data locations.
- [ ] Confirm whether external databases, APIs, or storage services are required.
- [ ] Confirm environment variables and application configuration.
- [ ] Compare source and target data where applicable.
- [ ] Validate backups and restore procedures.
- [ ] Obtain data-integrity sign-off from the application or data owner.

## 6. Monitoring and Operations

- [ ] Configure appropriate VM and application monitoring.
- [ ] Configure actionable alerts.
- [ ] Establish log retention and access controls.
- [ ] Document operational ownership and escalation contacts.
- [ ] Define performance and availability objectives.
- [ ] Test resource-exhaustion and service-failure scenarios.

## 7. Migration and Rollback

- [x] Migration procedure documented.
- [x] Rollback plan documented.
- [ ] Verify source and target image checksums match.
- [ ] Confirm source recovery procedure and access.
- [ ] Define cutover and rollback decision criteria.
- [ ] Confirm data synchronization requirements.
- [ ] Test rollback in a controlled environment.
- [ ] Obtain application-owner approval before cutover.

## 8. Cost Management

- [ ] Review estimated and actual cloud charges.
- [ ] Configure budget notifications.
- [ ] Confirm the VM size is suitable for expected workload.
- [ ] Review unused resources and external IP charges.
- [ ] Document ongoing operational costs.

## 9. Go/No-Go Decision

Current decision: NOT APPROVED FOR PRODUCTION CUTOVER.

Reason: The lab has demonstrated successful HTTP routing through the reverse proxy and API gateway, but persistent-data integrity, production security, capacity, high availability, and rollback readiness have not been fully verified.

Production approval requires the relevant technical checks to be completed and the responsible stakeholders to sign off.

## 10. Interview Summary

I migrated the available Docker application images from AWS EC2 to GCP Compute Engine, deployed the application services, configured the Docker network and reverse proxy, and validated the user, order, and payment routes. All six tested route requests returned HTTP 200 with the expected service responses.

I also documented security risks, data-integrity gaps, production readiness requirements, and rollback limitations. I would not declare a production cutover safe until data preservation, security, capacity, monitoring, and rollback had been validated.
