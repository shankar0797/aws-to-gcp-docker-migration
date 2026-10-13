# Security and Cost Considerations

## 1. Purpose

Document the security controls, risks, and cost considerations for the Docker application migrated from AWS EC2 to GCP Compute Engine.

## 2. Current GCP Environment

- VM: aws-migration-target
- Zone: asia-south1-c
- Machine type: e2-micro
- Network: default
- Network tag: migration-target
- Application endpoint: http://34.47.197.186:8081
- Application access: HTTP on port 8081

## 3. Firewall and Network Security

### Current configuration

The firewall rule `allow-migration-proxy-8081` allows inbound TCP traffic on port 8081 from `0.0.0.0/0` for VMs with the `migration-target` network tag.

This configuration enabled public access to the reverse proxy during testing.

### Security risk

Allowing traffic from `0.0.0.0/0` exposes the port to the public internet. This may be acceptable temporarily for a controlled lab test, but it should not be treated as a production-ready configuration.

### Recommended improvements

1. Restrict inbound traffic to approved client IP addresses where possible.
2. Permit SSH only through an approved access method, such as IAP or an authorized administration network.
3. Avoid exposing internal application ports directly to the internet.
4. Review firewall rules and VM network tags regularly.
5. Use HTTPS with a valid certificate for production traffic.
6. Remove temporary firewall rules when they are no longer required.

## 4. Application and Container Security

- Run containers with restart policies appropriate to the workload.
- Avoid running application processes as root when the images support non-root execution.
- Do not store passwords, API keys, or database credentials in source control.
- Use a managed secrets service for production secrets.
- Keep container images and the VM operating system patched.
- Review container logs for startup failures, errors, and unexpected requests.
- Verify which services require the forward-proxy image before deciding whether to run it.

## 5. Identity and Access Management

Apply least privilege to human users and service accounts.

Recommended controls:

- Grant only the IAM roles needed for each task.
- Avoid sharing personal credentials or service-account keys.
- Prefer managed identities and short-lived credentials where supported.
- Review permissions before production deployment.
- Record who is authorized to administer the VM and change firewall rules.

## 6. Cost Considerations

The lab uses an e2-micro VM to keep compute usage relatively small. Actual costs depend on the region, billing terms, VM runtime, disk, network usage, and other enabled resources.

Potential cost sources include:

- Compute Engine VM runtime.
- Persistent disk storage.
- External IPv4 address charges, where applicable.
- Network egress.
- Cloud Logging and Monitoring usage.
- Additional infrastructure introduced for production, such as load balancers, managed databases, backups, and HTTPS-related services.

### Cost-control actions

1. Stop the VM when it is not needed for the lab, after confirming that downtime is acceptable.
2. Delete unused disks, snapshots, images, and networking resources only after verifying they are no longer needed.
3. Set a budget and billing alerts.
4. Review actual charges in Cloud Billing.
5. Avoid leaving test resources running after validation.

Stopping a VM does not necessarily eliminate all charges. Persistent disks and some other resources may continue to incur costs.

## 7. Production Readiness Gaps

The following items have not been established as completed:

- HTTPS configuration.
- Restricted public ingress.
- Formal IAM review.
- Centralized secret management.
- Backup and restore testing.
- Production monitoring and alerting.
- Vulnerability scanning and image-signing controls.
- High availability and disaster recovery.
- A verified production rollback.

## 8. Conclusion

The current configuration demonstrates public HTTP access to a Docker-based application on GCP Compute Engine. The firewall rule and small VM are lab choices, not proof of production security or availability.

Before production use, review network exposure, identity permissions, secrets, backups, monitoring, reliability requirements, and the actual expected operating cost.
