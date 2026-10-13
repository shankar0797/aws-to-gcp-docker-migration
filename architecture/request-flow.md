# Application Request Flow

## 1. Objective

Explain how HTTP requests travel through the migrated Docker application hosted on GCP Compute Engine.

## 2. Request Flow Diagram

```text
Client
  |
  | HTTP request to port 8081
  v
GCP Firewall
  |
  v
Reverse Proxy (port 8081)
  |
  | Forwards request to api-gateway:8080
  v
API Gateway (port 8080)
  |
  +---- /users -----> User Service (port 8001)
  |
  +---- /orders ----> Order Service (port 8002)
  |
  +---- /payments --> Payment Service (port 8003)
  |
  v
HTTP response returned to the client
```

## 3. Step-by-Step Explanation

### Step 1: Client request

The client sends an HTTP request to the GCP VM on port 8081.

Example:

`http://<GCP_VM_EXTERNAL_IP>:8081/users`

### Step 2: Firewall evaluation

The GCP VPC firewall evaluates whether the request matches the ingress rule and the target VM's network tag.

For this lab, the rule `allow-migration-proxy-8081` permits TCP port 8081 for the VM tagged `migration-target`.

### Step 3: Reverse proxy

The reverse proxy listens on port 8081 and forwards application requests to the API gateway at `api-gateway:8080`.

The `/health` path is handled directly by the reverse proxy and returns its health message.

### Step 4: API gateway

The API gateway listens on port 8080 inside the Docker network. It routes requests based on the path:

- `/users` to `user-service:8001`
- `/orders` to `order-service:8002`
- `/payments` to `payment-service:8003`

The API gateway's `/health` path returns its own health message.

### Step 5: Application service

The selected service processes the request and returns its response to the API gateway.

### Step 6: Response to client

For requests sent through the reverse proxy, the response travels back through the API gateway and reverse proxy to the client.

## 4. Validation Performed

The following paths were tested through the API gateway and reverse proxy:

| Path | Expected service |
|---|---|
| `/users` | User service |
| `/orders` | Order service |
| `/payments` | Payment service |

All six tested requests returned HTTP 200 and the expected service-specific success responses.

Evidence: `evidence/command-outputs/11-gcp-route-validation.txt`

## 5. Troubleshooting Guide

If a request fails, check these layers in order:

1. **Network access:** Confirm the VM is running and the firewall rule matches the VM's network tag.
2. **Reverse proxy:** Check container status, logs, port mapping, and Nginx configuration.
3. **API gateway:** Verify it is running and can resolve `api-gateway` and the service container names on `backend-network`.
4. **Application services:** Check service status and logs.
5. **Routing:** Confirm the requested path and upstream port match the Nginx configuration.

Useful commands on the GCP VM:

```bash
sudo docker ps -a
sudo docker network inspect backend-network
sudo docker logs reverse-proxy --tail 50
sudo docker logs api-gateway --tail 50
sudo docker exec reverse-proxy nginx -t
sudo docker exec api-gateway nginx -t
```

## 6. Limitations

These tests demonstrate HTTP routing in the lab environment. They do not establish production capacity, HTTPS security, persistent-data integrity, or high availability.
