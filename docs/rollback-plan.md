# Rollback Plan: AWS EC2 to GCP Compute Engine

## 1. Purpose

Define how to stop a failed migration and recover application service using the source environment, if it is recoverable.

## 2. Rollback triggers

Consider rollback if any of the following occurs:

- Application routes fail after cutover.
- Required backend services remain unhealthy.
- Data validation fails or data is missing.
- Critical application errors appear in logs.
- Performance or availability does not meet agreed requirements.
- Security or connectivity requirements cannot be met.
- The application owner rejects the target deployment.

## 3. Preconditions

Before production cutover, confirm:

- The source EC2 instance and required application artifacts remain available.
- Source container images and configuration can be restored.
- Persistent data and external dependencies are identified.
- A verified backup exists for any required persistent data.
- The source application can be started and tested.
- DNS, load-balancer, or routing changes can be reversed.
- Owners and decision-makers have agreed on the rollback criteria.

Important: The source containers in this lab were already stopped before the migration. Source recovery has not been demonstrated.

## 4. Rollback procedure

1. Declare rollback and record the reason, time, and approver.
2. Stop further deployment changes on the GCP target.
3. Preserve target logs, configuration, and evidence for troubleshooting.
4. Determine whether any writes occurred on the target.
5. If target writes occurred, reconcile them safely before restoring traffic to the source. Do not discard or overwrite data without an approved recovery plan.
6. Recover the source EC2 environment using the documented startup procedure and known-good configuration.
7. Restore required persistent data from an appropriate backup if necessary.
8. Verify source container status, application health, dependencies, and representative application routes.
9. Restore traffic to the source through the approved DNS, load-balancer, or routing change.
10. Verify the service from an external client and monitor application errors.
11. Communicate the outcome and retain logs for root-cause analysis.

Do not route production traffic to a source environment until its health and data consistency have been verified.

## 5. Post-rollback validation

- Source application processes are running.
- Health endpoints return the expected responses.
- Representative application routes work.
- Required database and external dependencies are reachable.
- Data consistency has been checked.
- Monitoring shows no continuing critical errors.
- Stakeholders have confirmed service recovery.

## 6. Recovery limitations

- The source application was not running when this lab began.
- A successful source recovery has not been demonstrated.
- Persistent-data integrity has not yet been verified.
- No production traffic cutover or rollback exercise has been demonstrated.
- DNS rollback timing and recovery objectives have not been measured.

## 7. Exit criteria

Rollback is complete only after the approved recovery environment passes the required application, data, connectivity, and operational checks.

## 8. Lessons learned

A rollback plan is not sufficient on its own. Before production migration, test source recovery, backups, data reconciliation, routing reversal, and stakeholder communication in a controlled environment.
