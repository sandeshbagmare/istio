#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 01 (mTLS)..."
kubectl delete -f peer-auth-strict.yaml --ignore-not-found
kubectl delete -f mtls-test-clients.yaml --ignore-not-found
echo "[OK] Namespace back to PERMISSIVE; test clients removed."
