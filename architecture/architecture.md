# Application Architecture

## 1. Overview

This project migrates a Docker-based application from AWS EC2 to GCP Compute Engine.

The target VM hosts a reverse proxy, an API gateway, and three application services connected through a Docker bridge network named `backend-network`.

## 2. Target Architecture

```text
                         Client
                           |
                           | HTTP :8081
                           v
                GCP Compute Engine VM
                aws-migration-target
                           |
                           v
                     Reverse Proxy
                        :8081
                           |
                           | Proxy to API gateway
                           v
                      API Gateway
                        :8080
                           |
              +------------+------------+
              |            |            |
              v            v            v
         User Service  Order Service  Payment Service
             :8001         :8002          :8003

       Docker bridge network: backend-network
```

## 3. Components

| Component | Responsibility |
|---|---|
| GCP Compute Engine | Hosts the migrated Docker application |
| Reverse proxy | Receives HTTP requests on port 8081 and forwards them to the API gateway |
| API gateway | Routes requests to the appropriate application service |
| User service | Handles requests under `/users` |
| Order service | Handles requests under `/orders` |
| Payment service | Handles requests under `/payments` |
| Docker bridge network | Enables communication between application containers |
| GCP firewall rule | Allows inbound TCP port 8081 for the lab's tagged VM |

## 4. Request Flow

1. A client sends an HTTP request to the GCP VM on port 8081.
2. The GCP firewall rule permits the request when its source and target match the configured rule.
3. The reverse proxy forwards the request to the API gateway on port 8080.
4. The API gateway routes the request to the relevant service.
5. The service returns its response through the API gateway and reverse proxy to the client.

## 5. Validation

The following routes were tested and returned HTTP 200 with the expected service-specific response:

- `/users`
- `/orders`
- `/payments`

The routes were tested through both the API gateway and reverse proxy.

Evidence: `evidence/command-outputs/11-gcp-route-validation.txt`

## 6. Architecture Limitations

- The lab uses a single Compute Engine VM; VM-level high availability is not demonstrated.
- The public endpoint uses HTTP, not HTTPS.
- Persistent-data integrity and external dependencies have not been fully verified.
- The forward-proxy image exists, but its requirement in the request path is unknown.
- Production capacity and rollback have not been validated.

This diagram describes the tested lab architecture, not a production-ready reference architecture.
