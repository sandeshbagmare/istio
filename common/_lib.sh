#!/usr/bin/env bash
# ============================================================
# Shared helpers for every chapter's startup.sh / cleanup.sh
# Source it:   source "$(dirname "$0")/../common/_lib.sh"
# ============================================================
GREEN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[1;33m'; CY='\033[0;36m'; B='\033[1m'; NC='\033[0m'
say()  { echo -e "${CY}▶${NC} $*"; }
ok()   { echo -e "${GREEN}✔${NC} $*"; }
warn() { echo -e "${YEL}⚠${NC}  $*"; }
err()  { echo -e "${RED}x${NC} $*" >&2; }

check_prereqs() {
  command -v kubectl >/dev/null 2>&1 || { err "kubectl not found — run setup first."; exit 1; }
  kubectl cluster-info >/dev/null 2>&1 || { err "No cluster reachable — start Rancher/Docker Desktop, run setup."; exit 1; }
  kubectl get namespace istio-system >/dev/null 2>&1 || { err "Istio not installed — run setup first."; exit 1; }
  kubectl get deployment productpage-v1 >/dev/null 2>&1 || { err "Bookinfo not deployed — run setup first."; exit 1; }
}

# open_url <url> — best-effort cross-platform browser open
open_url() {
  local u="$1"
  if command -v cmd.exe >/dev/null 2>&1; then cmd.exe /c start "" "$u" >/dev/null 2>&1
  elif command -v open >/dev/null 2>&1; then open "$u"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$u"
  else echo "Open manually: $u"; fi
}

# ensure an in-mesh curl client exists (used to observe routing from inside the mesh)
ensure_curl_client() {
  if ! kubectl get deploy curl-client >/dev/null 2>&1; then
    say "Deploying in-mesh load client (curl-client)..."
    kubectl create deployment curl-client --image=curlimages/curl:latest -- sleep infinity >/dev/null 2>&1
  fi
  kubectl rollout status deploy/curl-client --timeout=120s >/dev/null 2>&1
}

# tally which reviews version answers, from inside the mesh
# usage: sample_reviews <count>
sample_reviews() {
  local n="${1:-50}"
  kubectl exec deploy/curl-client -- sh -c '
    v1=0;v2=0;v3=0
    for i in $(seq 1 '"$n"'); do
      r=$(curl -s http://reviews:9080/reviews/0)
      case "$r" in *reviews-v1*) v1=$((v1+1));; *reviews-v2*) v2=$((v2+1));; *reviews-v3*) v3=$((v3+1));; esac
    done
    echo "    reviews-v1 (no stars): $v1    reviews-v2 (black): $v2    reviews-v3 (red): $v3    [of '"$n"' requests]"'
}

# send N requests to the productpage through a temporary port-forward
# usage: gen_traffic <count>
gen_traffic() {
  local n="${1:-30}"
  kubectl port-forward -n istio-system svc/istio-ingressgateway 18080:80 >/dev/null 2>&1 &
  local pf=$!; sleep 3
  local ok=0
  for i in $(seq 1 "$n"); do
    code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:18080/productpage 2>/dev/null)
    [ "$code" = "200" ] && ok=$((ok+1))
    printf "\r  sent %d/%d  (HTTP 200: %d)" "$i" "$n" "$ok"
  done
  echo ""
  kill $pf >/dev/null 2>&1
}
