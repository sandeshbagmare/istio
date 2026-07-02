#!/usr/bin/env bash
cd "$(dirname "$0")"
echo "Cleaning up Chapter 04 (Fault Injection)..."
kubectl delete virtualservice ratings --ignore-not-found
echo "[OK] Faults removed - ratings is healthy again."
