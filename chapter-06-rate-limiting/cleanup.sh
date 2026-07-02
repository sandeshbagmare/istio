#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 06 (Rate Limiting)..."
kubectl delete -f local-ratelimit.yaml --ignore-not-found
echo "[OK] Rate limit removed."
