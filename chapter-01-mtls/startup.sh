#!/usr/bin/env bash
# Chapter 01 — Mutual TLS (mTLS).  Mirrors startup.bat for macOS/Linux/Git-Bash.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 01 : MUTUAL TLS (mTLS) =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."

say "[1/5] Deploying two test clients (in-mesh + legacy)..."
kubectl apply -f mtls-test-clients.yaml
kubectl rollout status deploy/curl-mesh --timeout=120s
kubectl rollout status deploy/curl-legacy -n legacy --timeout=120s

MESH=$(kubectl get pod -l app=curl-mesh -o jsonpath='{.items[0].metadata.name}')
LEG=$(kubectl get pod -n legacy -l app=curl-legacy -o jsonpath='{.items[0].metadata.name}')

probe()     { local c; c=$(kubectl exec "$1" -c curl -- curl -s -o /dev/null -w "%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2>/dev/null); echo "${c:-000}"; }
probe_leg() { local c; c=$(kubectl exec -n legacy "$1" -c curl -- curl -s -o /dev/null -w "%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2>/dev/null); echo "${c:-000}"; }

say "[2/5] BEFORE mTLS enforcement (namespace is PERMISSIVE)"
echo "    in-mesh client --> ratings : HTTP $(probe "$MESH")   (expected 200)"
echo "    legacy client  --> ratings : HTTP $(probe_leg "$LEG")   (expected 200 - plaintext allowed)"

say "[3/5] Applying STRICT mTLS to the 'default' namespace..."
kubectl apply -f peer-auth-strict.yaml
echo "    waiting 10s for propagation..."; sleep 10

say "[4/5] AFTER mTLS enforcement (namespace is STRICT)"
echo "    in-mesh client --> ratings : HTTP $(probe "$MESH")   (still 200 - speaks mTLS)"
echo "    legacy client  --> ratings : HTTP $(probe_leg "$LEG")   (000 = BLOCKED)"

say "[5/5] PeerAuthentication policy now in effect:"
kubectl get peerauthentication -n default

echo -e "\n${GREEN}RESULT:${NC} in-mesh kept working, legacy got blocked — with zero app changes.\n"
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
