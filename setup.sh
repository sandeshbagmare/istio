#!/usr/bin/env bash
# ============================================================
# Istio Learning Lab - Complete Setup Script
# Platform: Windows (Git Bash / MSYS2) or macOS / Linux
# ============================================================
set -euo pipefail

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

banner()  { echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════${NC}"; echo -e "${BLUE}${BOLD}  $1${NC}"; echo -e "${BLUE}${BOLD}═══════════════════════════════════════════${NC}\n"; }
step()    { echo -e "${CYAN}▶ $1${NC}"; }
ok()      { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
die()     { echo -e "${RED}❌ $1${NC}"; exit 1; }

# ── Detect OS ────────────────────────────────────────────────
OS="unknown"
case "$(uname -s 2>/dev/null)" in
  Darwin*)    OS="mac"     ;;
  Linux*)     OS="linux"   ;;
  MINGW*|MSYS*|CYGWIN*)  OS="windows" ;;
esac

banner "🚀 Istio Learning Lab — Setup"
echo "  Platform : $OS"
echo "  What we'll install:"
echo "    • Minikube   (local Kubernetes cluster)"
echo "    • Helm       (Kubernetes package manager)"
echo "    • Istioctl   (Istio control CLI)"
echo "    • Istio      (demo profile with all components)"
echo "    • Addons     (Kiali, Grafana, Jaeger, Prometheus)"
echo "    • Bookinfo   (sample microservices application)"
echo ""
echo "  Prerequisites:"
echo "    • Docker Desktop or Rancher Desktop must be running"
echo "    • Internet connection"
echo ""
read -rp "  Press ENTER to continue (Ctrl+C to cancel)..."

# ── Check Docker ─────────────────────────────────────────────
step "Checking Docker..."
docker info &>/dev/null || die "Docker is not running! Start Docker Desktop / Rancher Desktop first."
ok "Docker is running ($(docker version --format '{{.Server.Version}}' 2>/dev/null))"

# ── Install Function ─────────────────────────────────────────
install_tool() {
  local cmd=$1 installer=$2 desc=$3
  if command -v "$cmd" &>/dev/null; then
    ok "$desc already installed ($(${cmd} version --short 2>/dev/null || echo 'ok'))"
    return
  fi
  step "Installing $desc..."
  case "$OS" in
    mac)     brew install "$installer" ;;
    linux)   curl -fsSL "$installer" | bash ;;
    windows) cmd.exe //c "winget install $installer --silent --accept-source-agreements --accept-package-agreements" 2>/dev/null || warn "winget install failed — install $desc manually" ;;
  esac
}

# ── 1. Install Tools ─────────────────────────────────────────
banner "[1/8] Installing Tools"

# Minikube
if ! command -v minikube &>/dev/null; then
  step "Installing Minikube..."
  case "$OS" in
    mac)     brew install minikube ;;
    linux)   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
             sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64 ;;
    windows) cmd.exe //c "winget install Kubernetes.minikube --silent --accept-source-agreements --accept-package-agreements" 2>/dev/null
             # Also try direct download if winget fails
             if ! command -v minikube &>/dev/null; then
               warn "Trying direct download..."
               curl -Lo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-windows-amd64.exe 2>/dev/null || true
             fi ;;
  esac
else
  ok "Minikube already installed"
fi

# Helm
if ! command -v helm &>/dev/null; then
  step "Installing Helm..."
  case "$OS" in
    mac)     brew install helm ;;
    linux)   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ;;
    windows) cmd.exe //c "winget install Helm.Helm --silent --accept-source-agreements --accept-package-agreements" 2>/dev/null ;;
  esac
else
  ok "Helm already installed"
fi

# Istioctl
if ! command -v istioctl &>/dev/null; then
  step "Installing Istioctl..."
  case "$OS" in
    mac)     brew install istioctl ;;
    linux|windows)
      curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.23.0 sh -
      export PATH="$PWD/istio-1.23.0/bin:$PATH"
      ;;
  esac
else
  ok "Istioctl already installed"
fi

# ── 2. Start Minikube ─────────────────────────────────────────
banner "[2/8] Starting Minikube"

if minikube status 2>/dev/null | grep -q "Running"; then
  ok "Minikube already running"
else
  step "Starting Minikube (4 CPUs, 8GB RAM, 50GB disk)..."
  minikube start \
    --driver=docker \
    --memory=8192 \
    --cpus=4 \
    --disk-size=50g \
    --addons=ingress \
    --kubernetes-version=stable || {
    warn "Docker driver failed, trying without specifying driver..."
    minikube start --memory=8192 --cpus=4 --disk-size=50g
  }
  ok "Minikube started"
fi

kubectl config use-context minikube 2>/dev/null || true
ok "kubectl context → minikube"
echo ""
kubectl get nodes

# ── 3. Install Istio ──────────────────────────────────────────
banner "[3/8] Installing Istio Service Mesh"

if kubectl get namespace istio-system &>/dev/null; then
  ok "Istio already installed"
else
  step "Installing Istio with demo profile..."
  echo "  Profile includes: istiod, ingress-gateway, egress-gateway"
  istioctl install --set profile=demo -y
  ok "Istio installed"
fi

echo ""
step "Waiting for Istio control plane to be ready..."
kubectl wait --namespace istio-system \
  --for=condition=ready pod \
  -l app=istiod \
  --timeout=180s

kubectl wait --namespace istio-system \
  --for=condition=ready pod \
  -l app=istio-ingressgateway \
  --timeout=120s
ok "Istio control plane ready"

# Enable sidecar injection on default namespace
kubectl label namespace default istio-injection=enabled --overwrite
ok "Sidecar injection enabled on default namespace"

# ── 4. Install Addons ─────────────────────────────────────────
banner "[4/8] Installing Observability Addons"

ISTIO_ADDONS="https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons"

step "Installing Prometheus (metrics)..."
kubectl apply -f "$ISTIO_ADDONS/prometheus.yaml"

step "Installing Grafana (dashboards)..."
kubectl apply -f "$ISTIO_ADDONS/grafana.yaml"

step "Installing Jaeger (distributed tracing)..."
kubectl apply -f "$ISTIO_ADDONS/jaeger.yaml"

step "Installing Kiali (service mesh UI)..."
kubectl apply -f "$ISTIO_ADDONS/kiali.yaml"

echo ""
step "Waiting 30s for addons to initialize..."
sleep 30
ok "All addons installed"

# ── 5. Deploy Bookinfo ────────────────────────────────────────
banner "[5/8] Deploying Bookinfo Sample App"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if kubectl get deployment productpage-v1 &>/dev/null; then
  ok "Bookinfo already deployed"
else
  step "Deploying Bookinfo microservices..."
  kubectl apply -f "$SCRIPT_DIR/common/bookinfo.yaml"
  kubectl apply -f "$SCRIPT_DIR/common/bookinfo-gateway.yaml"

  step "Waiting for pods to be ready (2-3 minutes)..."
  kubectl wait --for=condition=ready pod -l app=productpage --timeout=300s
  kubectl wait --for=condition=ready pod -l app=details --timeout=300s
  kubectl wait --for=condition=ready pod -l app=reviews --timeout=300s
  kubectl wait --for=condition=ready pod -l app=ratings --timeout=300s
  ok "Bookinfo deployed"
fi

echo ""
kubectl get pods
echo ""
echo "Each pod should show 2/2 containers (app + Istio sidecar proxy)"

# ── 6. Verify Sidecar Injection ───────────────────────────────
banner "[6/8] Verifying Istio Sidecar Injection"

CONTAINERS=$(kubectl get pod -l app=productpage -o jsonpath='{.items[0].status.containerStatuses[*].name}' 2>/dev/null || echo "")
if echo "$CONTAINERS" | grep -q "istio-proxy"; then
  ok "Istio sidecar (Envoy proxy) is injected into pods ✓"
  echo "  productpage pod containers: $CONTAINERS"
else
  warn "Sidecar may not be injected yet. Pods might still be starting."
fi

# ── 7. Get App URL ────────────────────────────────────────────
banner "[7/8] Application Access Info"

INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}' 2>/dev/null || echo "80")
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "127.0.0.1")

echo "  Minikube IP:   $MINIKUBE_IP"
echo "  Ingress Port:  $INGRESS_PORT"
echo ""
echo "  Method 1 (NodePort):"
echo "    http://$MINIKUBE_IP:$INGRESS_PORT/productpage"
echo ""
echo "  Method 2 (minikube tunnel - recommended):"
echo "    Run in a NEW terminal: minikube tunnel"
echo "    Then visit: http://localhost/productpage"

# ── 8. Verify All Chapters ────────────────────────────────────
banner "[8/8] Chapter Readiness Check"

echo ""
CHAPTERS=(
  "chapter-01-foundation"
  "chapter-02-mtls"
  "chapter-03-canary"
  "chapter-04-header-routing"
  "chapter-05-fault-injection"
  "chapter-06-circuit-breaker"
  "chapter-07-kiali"
  "chapter-08-jaeger"
  "chapter-09-grafana"
  "chapter-10-authorization"
)

ALL_OK=true
for ch in "${CHAPTERS[@]}"; do
  if [ -f "$SCRIPT_DIR/$ch/startup.sh" ]; then
    ok "$ch — startup.sh ✓"
  else
    warn "$ch — startup.sh MISSING"
    ALL_OK=false
  fi
done

echo ""
if $ALL_OK; then
  ok "All 10 chapters are ready!"
else
  warn "Some chapters are missing files. Re-run setup or check the folders."
fi

# ── Done! ─────────────────────────────────────────────────────
banner "🎉 SETUP COMPLETE!"

echo "  ┌─────────────────────────────────────────────┐"
echo "  │  Getting Started                             │"
echo "  │                                             │"
echo "  │  1. Open index.html in your browser         │"
echo "  │     for the full interactive guide          │"
echo "  │                                             │"
echo "  │  2. Start tunnel (new terminal):            │"
echo "  │     minikube tunnel                         │"
echo "  │                                             │"
echo "  │  3. Visit the app:                          │"
echo "  │     http://localhost/productpage            │"
echo "  │                                             │"
echo "  │  4. Run any chapter demo:                   │"
echo "  │     cd chapter-01-foundation                │"
echo "  │     bash startup.sh                         │"
echo "  │     (or double-click startup.bat)           │"
echo "  └─────────────────────────────────────────────┘"
echo ""
echo "  Installed versions:"
command -v minikube   &>/dev/null && echo "    minikube : $(minikube version --short 2>/dev/null)"
command -v istioctl   &>/dev/null && echo "    istioctl : $(istioctl version --remote=false 2>/dev/null | head -1)"
command -v kubectl    &>/dev/null && echo "    kubectl  : $(kubectl version --client --short 2>/dev/null)"
command -v helm       &>/dev/null && echo "    helm     : $(helm version --short 2>/dev/null)"
echo ""
