#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 03 (Traffic Routing)..."
kubectl delete virtualservice reviews --ignore-not-found
echo "[OK] Routing rule removed."
