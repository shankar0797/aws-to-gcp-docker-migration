#!/usr/bin/env bash
set -u

echo "===== DOCKER HEALTH CHECK ====="
date -Is

echo "===== DOCKER SERVICE ====="
sudo systemctl is-active docker || true

echo "===== CONTAINER STATUS ====="
sudo docker ps -a

echo "===== DOCKER IMAGES ====="
sudo docker images

echo "===== APPLICATION ENDPOINTS ====="
for endpoint in \
  http://127.0.0.1:8081/health \
  http://127.0.0.1:8081/users \
  http://127.0.0.1:8081/orders \
  http://127.0.0.1:8081/payments
do
  echo "--- $endpoint"
  curl --connect-timeout 5 --max-time 10 -sS -w '\nHTTP status: %{http_code}\n' "$endpoint" || true
done

echo "===== HEALTH CHECK COMPLETE ====="
