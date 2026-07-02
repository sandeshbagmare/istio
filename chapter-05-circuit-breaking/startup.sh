#!/usr/bin/env bash
# Chapter 05 — Circuit Breaking.  Mirrors startup.bat.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 05 : CIRCUIT BREAKING =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."

say "[1/4] Deploying target (httpbin) + load tool (fortio)..."
kubectl apply -f httpbin-deploy.yaml
kubectl apply -f fortio-deploy.yaml
kubectl rollout status deploy/httpbin --timeout=150s
kubectl rollout status deploy/fortio  --timeout=150s

echo -e "\n${B}[2/4] BASELINE${NC} — no breaker, 3 parallel callers (expect ~100% 200)"
kubectl exec deploy/fortio -c fortio -- fortio load -c 3 -qps 0 -n 30 http://httpbin:8000/get 2>&1 | grep -E "Code [0-9]|Sockets used"

say "[3/4] Applying the circuit breaker (max 1 conn, 1 pending request)..."
kubectl apply -f circuit-breaker.yaml; sleep 3

echo -e "\n${B}[4/4] WITH BREAKER${NC} — same 3 parallel callers (excess -> fast 503)"
kubectl exec deploy/fortio -c fortio -- fortio load -c 3 -qps 0 -n 30 http://httpbin:8000/get 2>&1 | grep -E "Code [0-9]|Sockets used"

echo -e "\n${GREEN}RESULT:${NC} excess concurrent calls fail fast with 503 instead of overloading httpbin. Try -c 5 or -c 10.\n"
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
