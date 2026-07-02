#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 05 (Circuit Breaking)..."
kubectl delete -f circuit-breaker.yaml --ignore-not-found
kubectl delete -f fortio-deploy.yaml --ignore-not-found
kubectl delete -f httpbin-deploy.yaml --ignore-not-found
echo "[OK] Circuit breaker, fortio and httpbin removed."
