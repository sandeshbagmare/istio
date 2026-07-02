#!/usr/bin/env bash
# Chapter 04 — Fault Injection.  Mirrors startup.bat.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 04 : FAULT INJECTION =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."
ensure_curl_client

echo -e "\n${B}BASELINE${NC} — ratings is healthy"
kubectl exec deploy/curl-client -- sh -c 'c=$(curl -s -o /dev/null -w %{http_code} http://ratings:9080/ratings/0); t=$(curl -s -o /dev/null -w %{time_total} http://ratings:9080/ratings/0); echo "    status=$c   latency=${t}s"'

echo -e "\n${B}DEMO 1 — ABORT${NC} inject HTTP 500 into 50% of calls"
kubectl apply -f fault-abort.yaml; sleep 3
kubectl exec deploy/curl-client -- sh -c 'ok=0;e5=0;n=0; while [ $n -lt 20 ]; do c=$(curl -s -o /dev/null -w %{http_code} http://ratings:9080/ratings/0); case $c in 200) ok=$((ok+1));; 500) e5=$((e5+1));; esac; n=$((n+1)); done; echo "    HTTP-200=$ok   HTTP-500(injected)=$e5   [of 20]"'

echo -e "\n${B}DEMO 2 — DELAY${NC} add 3s delay to 100% of calls"
kubectl apply -f fault-delay.yaml; sleep 3
kubectl exec deploy/curl-client -- sh -c 't=$(curl -s -o /dev/null -w %{time_total} http://ratings:9080/ratings/0); echo "    one request now took ${t}s   [expected ~3s]"'

echo -e "\n${GREEN}RESULT:${NC} a healthy service made to look broken & slow with pure config — ratings code untouched.\n"
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
