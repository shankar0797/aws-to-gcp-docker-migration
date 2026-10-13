# AWS-to-GCP Docker Migration — Revision Cheatsheet

## 1. Project in one sentence

Migrated a Docker-based microservices lab from an AWS EC2 source environment to a Google Cloud Compute Engine VM, loaded container images, recreated the Docker network and service containers, configured reverse-proxy access, and validated health and application routes.

> **Be accurate in interviews:** This was a hands-on lab migration and validation, not a production cutover. The source containers were stopped during inventory. Production database/persistent-data migration, high availability, and zero downtime were not demonstrated.

## 2. Architecture

```text
Client / Browser
      | HTTP :8081
      v
GCP external IP: 34.47.197.186
      |
Firewall: allow-migration-proxy-8081
Target network tag: migration-target
      |
Compute Engine VM: aws-migration-target
Zone: asia-south1-c | Machine: e2-micro
      |
      v
reverse-proxy:1.1 (:8081)
      | Docker DNS on backend-network
      v
api-gateway:1.0 (:8080)
      +---- /users    ---> user-service:1.0    (:8001)
      +---- /orders   ---> order-service:1.0   (:8002)
      +---- /payments ---> payment-service:1.0 (:8003)
```

### Core concepts
- **Compute Engine:** GCP virtual machines; broadly comparable to AWS EC2.
- **Image:** Packaged application and runtime used to create containers.
- **Container:** A running or stopped instance created from an image.
- **Docker bridge network:** Lets containers communicate by service/container name.
- **Reverse proxy:** External entry point, listening on host port 8081.
- **API gateway:** Routes requests to the relevant backend microservice.
- **Firewall rule + network tag:** The ingress rule targets VMs with the matching tag.

## 3. Environment facts

| Item | Value |
|---|---|
| GitHub repository | `shankar0797/aws-to-gcp-docker-migration` |
| Local folder | `D:\downloads\aws-to-gcp-docker-migration` |
| GCP VM | `aws-migration-target` |
| GCP zone | `asia-south1-c` |
| Machine type | `e2-micro` |
| External IP observed during lab | `34.47.197.186` |
| Docker network | `backend-network` |
| Public lab endpoint | `http://34.47.197.186:8081/health` |

The external IP may change if it is ephemeral. Verify it before a demo.

## 4. Routes and validation

| Route | Expected result |
|---|---|
| Reverse proxy `/health` | HTTP 200, `Reverse Proxy is healthy` |
| API gateway `/health` on port 8080 | HTTP 200, `API Gateway is healthy` |
| `/users` | HTTP 200 from user service |
| `/orders` | HTTP 200 from order service |
| `/payments` | HTTP 200 from payment service |

The three application routes were tested through both the API gateway and reverse proxy and returned HTTP 200. The public reverse-proxy health endpoint also returned HTTP 200. This proves the tested routes worked at that time—not load capacity, resilience, or production readiness.

## 5. Migration sequence

1. **Inventory source:** OS, CPU, memory, disk, Docker version, images, containers, networks, volumes, and listening ports.
2. **Assess dependencies:** Configuration, secrets, network dependencies, databases, and persistent storage.
3. **Prepare GCP:** VM, SSH, Docker, disk space, firewall rule, and network tag.
4. **Transfer/load images:** Confirm images with `docker images`.
5. **Recreate Docker networking:** Create `backend-network`.
6. **Start services:** Backend services, then API gateway, then reverse proxy.
7. **Validate from inside outward:** Container state → network/DNS → gateway health/routes → proxy routes → public endpoint.
8. **Capture evidence:** Save actual outputs, document limitations, commit, and push to GitHub.

## 6. Commands to remember

### SSH from Windows PowerShell

```powershell
gcloud compute ssh aws-migration-target `
  --project=project-f88803f7-8e57-4b23-a50 `
  --zone=asia-south1-c
```

### Copy a GCP output file to Windows

Run in PowerShell, outside the SSH session:

```powershell
gcloud compute scp `
  --project=project-f88803f7-8e57-4b23-a50 `
  --zone=asia-south1-c `
  aws-migration-target:target-validation-output.txt `
  .\evidence\command-outputs\02-gcp-target-validation.txt
```

Using `instance:filename` worked reliably in this Windows setup. The warning about a space in the local Windows username was not fatal.

### Docker inspection (inside VM)

```bash
sudo docker ps -a
sudo docker images --digests
sudo docker network ls
sudo docker network inspect backend-network
sudo docker volume ls
sudo docker logs --tail 100 reverse-proxy
sudo docker logs --tail 100 api-gateway
```

### VM and listening ports

```bash
sudo systemctl is-active docker
sudo ss -lntup
free -h
df -hT
nproc
```

### Test routes from the VM

```bash
curl -i --connect-timeout 5 --max-time 10 http://127.0.0.1:8081/health
curl -i --connect-timeout 5 --max-time 10 http://127.0.0.1:8081/users
curl -i --connect-timeout 5 --max-time 10 http://127.0.0.1:8081/orders
curl -i --connect-timeout 5 --max-time 10 http://127.0.0.1:8081/payments
```

### Test gateway over Docker network

```bash
sudo docker run --rm --network backend-network \
  curlimages/curl:latest -i http://api-gateway:8080/health
```

### Git essentials

```powershell
git status
git log -1 --oneline
git remote -v
git add .
git commit -m "Update migration documentation and evidence"
git push
```

Review staged changes and check for secrets before committing.

## 7. Troubleshooting stories

### Public endpoint timed out
- **Symptom:** Public request to GCP IP on TCP/8081 timed out.
- **Cause:** Firewall rule targeted `migration-target`, but the VM initially lacked that tag.
- **Fix:** Added the matching tag and retested successfully.
- **Lesson:** Check firewall direction, protocol/port, source range, target tag, VM external IP, and listening process.

### Container not working
```bash
sudo systemctl status docker
sudo docker ps -a
sudo docker logs --tail 100 <container-name>
sudo docker inspect <container-name>
```
An image existing does not prove its container is running. Check state, logs, exit code, port binding, configuration, and network.

### Service-to-service connectivity failure
```bash
sudo docker network inspect backend-network
sudo docker exec api-gateway getent hosts user-service
```
If `getent` is unavailable in the image, use a diagnostic container. Verify both containers share the network, the service name/port is correct, and the app is listening.

### SCP says remote file not found
Generate the output file on the VM first, confirm it with `ls -lh`, then copy it. In this Windows setup, `instance:filename` worked better than `instance:~/filename`.

### Wrong GCP project/API error
The CLI was pointing at `my-project`, not the intended project. Verify:
```powershell
gcloud config get-value project
```
Use the intended project ID explicitly. Do not enable APIs or change IAM in an unintended project.

## 8. Source inventory facts

The AWS inventory recorded:
- Amazon Linux 2023, 2 vCPU, about 913 MiB RAM, 12 GB root disk.
- Docker 25.0.14.
- Images for reverse proxy, API gateway, user, order, payment, and forward proxy.
- Six application containers were stopped during inventory; some showed exit code 137.
- `backend-network` existed.
- No Docker volumes were listed.
- SSH was the only TCP listener observed.

Exit code 137 commonly means a process was killed, but it does not by itself establish the cause. No listed Docker volumes does not prove there was no persistent data elsewhere. The source application was not shown to be healthy and running at inventory time.

## 9. Limitations — say these honestly

- Lab migration, not production cutover.
- Source containers were stopped during inventory; do not claim zero downtime.
- Database migration, persistent-data migration, and data-integrity comparison were not demonstrated.
- No Docker volumes were listed, but other storage/dependencies were not ruled out.
- Target is one `e2-micro` VM; no multi-zone HA, autoscaling, or load test was demonstrated.
- Lab firewall allowed TCP/8081 from `0.0.0.0/0`; too broad for production.
- Public demo used HTTP, not HTTPS.
- Production secrets management, CI/CD, monitoring/alerting, backup/restore, and disaster-recovery validation were not demonstrated.
- `forward-proxy:1.0` image existed, but its target operational requirement was not established.

## 10. Production improvements

- HTTPS, managed certificates, and a domain.
- Restrict ingress to approved sources and expose only necessary ports.
- Secret Manager and least-privilege IAM/service accounts.
- Decide between VMs and a managed container platform based on requirements.
- Multi-zone design, autoscaling, health checks, rolling deployments, monitoring, and alerting.
- Identify databases, queues, files, volumes, and external dependencies; plan backups, replication, cutover, and rollback.
- Capacity, failure-recovery, vulnerability, and restore testing.
- CI/CD, image scanning, and configuration management.

## 11. Interview explanation (60–90 seconds)

“I built a hands-on migration lab to move a Docker-based microservices application from an AWS EC2 environment to a Google Cloud Compute Engine VM. I first inventoried the source OS, compute and disk resources, Docker images, containers, networks, volumes, and listening ports. On GCP, I prepared the VM, loaded the application images, recreated the Docker bridge network, and started the backend services, API gateway, and reverse proxy. The reverse proxy exposed port 8081 and forwarded requests to the API gateway on port 8080; the gateway routed `/users`, `/orders`, and `/payments` to their services. I validated container state, internal API health, all three routes through both the gateway and proxy, and the public health endpoint. I documented troubleshooting, evidence, rollback considerations, security, and cost. It was a lab rather than a production cutover: persistent data and database migration were not proven, and I would add HTTPS, restricted ingress, high availability, monitoring, and recovery tests before production.”

## 12. Common interview questions

**Why inventory first?** To understand dependencies and state, identify what must move, and avoid migrating blindly.

**Why Docker networking?** Containers can resolve service names and communicate without hard-coding IP addresses.

**Reverse proxy vs API gateway?** The reverse proxy is the external entry point; the gateway routes to the backend service. In a small lab, the roles could be combined, but separation clarifies responsibilities.

**What proved it worked?** Container/image checks, gateway health, HTTP 200 for user/order/payment routes through both gateway and proxy, and public proxy health.

**Was it zero downtime?** No. Zero downtime was not established; source containers were stopped during inventory and no production cutover was measured.

**Was the database migrated?** Not demonstrated. The proven scope was container images, service/network recreation, and route validation.

**What caused the timeout?** The VM lacked the network tag targeted by the firewall rule; adding the tag fixed reachability.

**Why not expose all service ports?** Only the entry point should be externally reachable; backend services should stay on the private Docker network unless needed.

**What would you monitor?** CPU, memory, disk, network, container restarts/logs, endpoint latency/errors, and backend health.

**Biggest production gap?** Single small VM, broad public HTTP ingress, and unproven database/data migration and recovery.

## 13. Evidence files

At the latest check, `evidence/command-outputs/` contained:
- `01-aws-source-inventory.txt`
- `02-gcp-target-validation.txt`
- `03-gcp-docker-health-check.txt`
- `05-gcp-vm-details.txt`
- `06-gcp-docker-images.txt`
- `07-gcp-container-status.txt`
- `11-gcp-route-validation.txt`

Use real captured output and redact secrets or sensitive details before publishing.

## 14. Final revision checklist

- [ ] Explain source and target architecture.
- [ ] Explain inventory and migration sequence.
- [ ] Know image vs container vs network.
- [ ] Explain reverse proxy vs API gateway.
- [ ] Explain firewall rule/network tag troubleshooting.
- [ ] Recall health checks and route tests.
- [ ] Explain container and network troubleshooting.
- [ ] Show evidence and GitHub documentation.
- [ ] State gaps honestly: data, DB, HA, security, zero downtime.
- [ ] Describe production-readiness improvements.
