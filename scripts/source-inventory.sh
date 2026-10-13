#!/usr/bin/env bash
# Collect a read-only inventory of a Linux Docker source host.
# Run on the source VM before migration.

set -u

echo "===== SOURCE HOST INVENTORY ====="
date -Is
hostname
uname -a

echo
echo "===== OPERATING SYSTEM ====="
if [ -r /etc/os-release ]; then
    cat /etc/os-release
else
    echo "/etc/os-release not available"
fi

echo
echo "===== CPU AND MEMORY ====="
nproc
free -h

echo
echo "===== DISK USAGE ====="
df -hT

echo
echo "===== DOCKER VERSION ====="
if command -v docker >/dev/null 2>&1; then
    docker --version

    echo
    echo "===== CONTAINER STATUS ====="
    docker ps -a --no-trunc

    echo
    echo "===== LOCAL IMAGES ====="
    docker images --digests

    echo
    echo "===== DOCKER NETWORKS ====="
    docker network ls

    echo
    echo "===== DOCKER VOLUMES ====="
    docker volume ls
else
    echo "Docker is not installed or is not in PATH."
fi

echo
echo "===== LISTENING TCP/UDP SOCKETS ====="
if command -v ss >/dev/null 2>&1; then
    ss -lntup
else
    echo "ss command is not available"
fi

echo
echo "===== INVENTORY COMPLETE ====="
echo "Review output for secrets or sensitive details before sharing."
