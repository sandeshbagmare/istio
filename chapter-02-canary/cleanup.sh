#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 02 (Canary)..."
kubectl delete virtualservice reviews --ignore-not-found
echo "[OK] Reviews routing rule removed."
