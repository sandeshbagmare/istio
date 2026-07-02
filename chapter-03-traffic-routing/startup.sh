#!/usr/bin/env bash
# Chapter 03 — Content-based routing.  Mirrors startup.bat.
set -uo pipefail
cd "$(dirname "$0")"
source "../common/_lib.sh"

echo -e "\n${B}===== CHAPTER 03 : CONTENT-BASED TRAFFIC ROUTING =====${NC}\n"
check_prereqs
ok "Cluster, Istio and Bookinfo are ready."
ensure_curl_client

say "Applying routing rule (jason -> v2, everyone else -> v1)..."
kubectl apply -f reviews-route-by-user.yaml; sleep 3

count() { # $1 = optional header args
  kubectl exec deploy/curl-client -- sh -c "v1=0; v2=0; n=0; while [ \$n -lt 10 ]; do r=\$(curl -s $1 http://reviews:9080/reviews/0); case \$r in *reviews-v1*) v1=\$((v1+1));; *reviews-v2*) v2=\$((v2+1));; esac; n=\$((n+1)); done; echo \"    served by  v1=\$v1  v2=\$v2\""
}

echo -e "\n${B}TEST A${NC} — anonymous user (no header)   [expect all v1]"
count ""
echo -e "\n${B}TEST B${NC} — user 'jason' (end-user: jason) [expect all v2]"
count "-H end-user:jason"

echo -e "\n${GREEN}RESULT:${NC} same URL, response version chosen by request identity — the engine behind A/B tests & dark launches.\n"
echo "SEE IT: port-forward the ingress, open /productpage, then 'Sign in' as jason -> stars appear."
open_url "file://$(pwd)/guide.html"
echo "Run ./cleanup.sh when done."
