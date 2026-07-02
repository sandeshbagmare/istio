#!/usr/bin/env bash
# Chapter 02 — Canary Deployments.  Mirrors startup.bat.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 02 : CANARY DEPLOYMENTS =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."
ensure_curl_client

echo -e "\n${B}STEP 0${NC} — baseline: 100% of reviews traffic on v1"
kubectl apply -f reviews-all-v1.yaml; sleep 3; sample_reviews 50

echo -e "\n${B}STEP 1${NC} — release v3 to 10% of users (the canary)"
kubectl apply -f reviews-canary-90-10.yaml; sleep 3; sample_reviews 50

echo -e "\n${B}STEP 2${NC} — widen the rollout to 50/50"
kubectl apply -f reviews-canary-50-50.yaml; sleep 3; sample_reviews 50

echo -e "\n${B}STEP 3${NC} — promote v3 to 100% (rollout complete)"
kubectl apply -f reviews-canary-100-v3.yaml; sleep 3; sample_reviews 50

echo -e "\n${GREEN}RESULT:${NC} traffic moved v1 -> v3 by changing only a weight number. No redeploys.\n"
echo "TIP: kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80  then open http://localhost:8080/productpage"
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
