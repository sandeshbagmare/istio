#!/usr/bin/env bash
# Chapter 06 — Rate Limiting.  Mirrors startup.bat.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 06 : RATE LIMITING =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."
ensure_curl_client

burst() {
  kubectl exec deploy/curl-client -- sh -c 'ok=0; rl=0; n=0; while [ $n -lt 20 ]; do c=$(curl -s -o /dev/null -w %{http_code} http://productpage:9080/productpage); case $c in 200) ok=$((ok+1));; 429) rl=$((rl+1));; esac; n=$((n+1)); done; echo "    HTTP-200(allowed)=$ok   HTTP-429(limited)=$rl   [of 20]"'
}

echo -e "\n${B}BEFORE${NC} — no rate limit, fire 20 requests (expect all 200)"
burst

say "Applying local rate limit (burst of 5 per 60s)..."
kubectl apply -f local-ratelimit.yaml; sleep 5

echo -e "\n${B}AFTER${NC} — same 20 requests, now throttled"
burst

echo -e "\n${GREEN}RESULT:${NC} once the burst is spent, extra requests get HTTP 429. (Token bucket is per worker-thread, so the cut-off can vary a little.)\n"
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
