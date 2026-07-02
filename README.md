# 🚀 Istio Learning Lab — 10 Hands-On Chapters

A complete, **click-to-run** lab that teaches [Istio](https://istio.io) service mesh from zero.
Every chapter is a self-contained demo: double-click **`startup.bat`**, watch it run against a real
Kubernetes cluster, and read the illustrated **`guide.html`** that explains *what happened, why it
matters, and how to view it*.

Built and tested on **Windows 11 + Rancher Desktop (k3s) + Docker**, but the `.sh` scripts make it work
on macOS/Linux too.

---

## 📚 The 10 Chapters

| # | Chapter | What you learn | Istio object(s) |
|---|---------|----------------|-----------------|
| 01 | **Mutual TLS** | Auto-encrypt & authenticate all service-to-service traffic | `PeerAuthentication` |
| 02 | **Canary Deployments** | Shift traffic 10% → 50% → 100% to a new version | `VirtualService` (weights) |
| 03 | **Traffic Routing** | Route by user / header / path (A/B tests, dark launch) | `VirtualService` (match) |
| 04 | **Fault Injection** | Inject delays & errors to test resilience | `VirtualService` (fault) |
| 05 | **Circuit Breaking** | Stop cascading failures by ejecting bad hosts | `DestinationRule` (outlier) |
| 06 | **Rate Limiting** | Protect services with request quotas (HTTP 429) | `EnvoyFilter` (local RL) |
| 07 | **Kiali Dashboard** | *See* your mesh — the live topology graph | Kiali addon |
| 08 | **Grafana + Prometheus** | Golden-signal metrics & dashboards | Prometheus + Grafana |
| 09 | **Jaeger Tracing** | Follow one request across every service | Jaeger addon |
| 10 | **Traffic Mirroring** | Shadow live traffic to a new version risk-free | `VirtualService` (mirror) |

---

## ✅ Prerequisites

1. **Docker** running (via **Rancher Desktop** or **Docker Desktop**) with **Kubernetes enabled**.
2. **kubectl** on your PATH (Rancher/Docker Desktop install this for you).
3. An internet connection (first run downloads `istioctl`, the Istio images, and the addons).
4. ~4 GB of RAM free for the cluster.

> This lab installs Istio into whatever Kubernetes cluster `kubectl` currently points at. If you have
> no cluster, `setup.bat` will offer to start **minikube**.

---

## ⚡ Quick Start

```bat
:: 1. Double-click (or run) the top-level installer — does EVERYTHING:
setup.bat
```

`setup.bat` will:
1. Verify Docker & a reachable Kubernetes cluster.
2. Download **istioctl 1.30.2** into `tools\bin\`.
3. Install **Istio** (demo profile, memory-tuned for a laptop).
4. Install the **Kiali / Grafana / Prometheus / Jaeger** addons.
5. Deploy the **Bookinfo** sample app + destination rules.
6. Verify every pod is healthy and every chapter folder is present.

Then open **`index.html`** for the guided tour, or jump straight into a chapter:

```bat
cd chapter-01-mtls
startup.bat        :: runs the demo + opens guide.html
:: ... explore ...
cleanup.bat        :: resets the mesh for the next chapter
```

macOS / Linux users: run `bash setup.sh`, then `bash chapter-01-mtls/startup.sh`.

---

## 🌐 How to view the apps & dashboards

Because k3s/Rancher already uses ports 80/443 (Traefik), this lab accesses everything through
**`kubectl port-forward`** — reliable and identical on every platform:

| What | Command | URL |
|------|---------|-----|
| Bookinfo app | `kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80` | http://localhost:8080/productpage |
| Kiali | `kubectl port-forward -n istio-system svc/kiali 20001:20001` | http://localhost:20001 |
| Grafana | `kubectl port-forward -n istio-system svc/grafana 3000:3000` | http://localhost:3000 |
| Prometheus | `kubectl port-forward -n istio-system svc/prometheus 9090:9090` | http://localhost:9090 |
| Jaeger | `kubectl port-forward -n istio-system svc/tracing 16686:80` | http://localhost:16686 |

The dashboard chapters (07–09) start these port-forwards for you.

---

## 🧱 Repo layout

```
istio/
├── setup.bat / setup.sh        # one-shot installer for the whole lab
├── run-all.bat                 # validate all 10 chapters are present & healthy
├── teardown.bat / teardown.sh  # remove Istio + demo apps
├── index.html                  # the illustrated landing page / tour
├── common/                     # shared bookinfo, destination rules, helpers, CSS
└── chapter-XX-name/
    ├── startup.bat / .sh       # run the demo
    ├── cleanup.bat / .sh       # reset the mesh
    ├── guide.html              # the illustrated explanation
    └── *.yaml                  # the Istio manifests for that chapter
```

---

## 🧹 Teardown

```bat
teardown.bat     :: removes Istio, the addons, Bookinfo and demo resources
```

Your Kubernetes cluster (Rancher/Docker Desktop) is left running.

---

## 🛠️ Troubleshooting

- **"No cluster reachable"** — start Rancher/Docker Desktop and enable Kubernetes, then re-run `setup.bat`.
- **A pod is stuck `Pending`** — you're low on RAM; close apps or give the cluster more memory.
- **`startup.bat` says Istio/Bookinfo missing** — run the top-level `setup.bat` first.
- **Port already in use** — another `kubectl port-forward` is running; close that window.

---

*Built as an educational reference. Bookinfo is Istio's official sample app.*
