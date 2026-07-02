@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo    ╔══════════════════════════════════════════════════════════════╗
echo    ║                                                              ║
echo    ║        ██████╗ ██████╗  █████╗ ███████╗ █████╗ ███╗   ██╗   ║
echo    ║       ██╔════╝ ██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗  ██║   ║
echo    ║       ██║  ███╗██████╔╝███████║█████╗  ███████║██╔██╗ ██║   ║
echo    ║       ██║   ██║██╔══██╗██╔══██║██╔══╝  ██╔══██║██║╚██╗██║   ║
echo    ║       ╚██████╔╝██║  ██║██║  ██║██║     ██║  ██║██║ ╚████║   ║
echo    ║        ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝   ║
echo    ║                                                              ║
echo    ║    ██████╗ ██████╗  ██████╗ ███╗   ███╗███████╗████████╗     ║
echo    ║    ██╔══██╗██╔══██╗██╔═══██╗████╗ ████║██╔════╝╚══██╔══╝     ║
echo    ║    ██████╔╝██████╔╝██║   ██║██╔████╔██║█████╗     ██║        ║
echo    ║    ██╔═══╝ ██╔══██╗██║   ██║██║╚██╔╝██║██╔══╝     ██║        ║
echo    ║    ██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗   ██║        ║
echo    ║    ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝   ╚═╝        ║
echo    ║                                                              ║
echo    ║          Chapter 8: Grafana ^& Prometheus                    ║
echo    ║          Metrics-Driven Observability                        ║
echo    ║                                                              ║
echo    ╚══════════════════════════════════════════════════════════════╝
echo.

echo ══════════════════════════════════════════════════════════════
echo  [1/4] Deploying Traffic Generator (Fortio)...
echo ══════════════════════════════════════════════════════════════
kubectl apply -f generate-traffic.yaml
echo.

echo ══════════════════════════════════════════════════════════════
echo  [2/4] Waiting for pods to initialize...
echo ══════════════════════════════════════════════════════════════
timeout /t 10 /nobreak >nul
echo  ✓ Wait complete.
echo.

echo ══════════════════════════════════════════════════════════════
echo  [3/4] Starting Port Forwards...
echo ══════════════════════════════════════════════════════════════
echo  → Grafana    : localhost:3000
start /b kubectl port-forward svc/grafana -n istio-system 3000:3000 >nul 2>&1
echo  → Prometheus : localhost:9090
start /b kubectl port-forward svc/prometheus -n istio-system 9090:9090 >nul 2>&1
echo  ✓ Port forwards active.
echo.

echo ══════════════════════════════════════════════════════════════
echo  [4/4] Opening Learning Guide...
echo ══════════════════════════════════════════════════════════════
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │                                                          │
echo  │   GRAFANA  → http://localhost:3000                       │
echo  │   Navigate: Dashboards ^> Browse ^> istio                │
echo  │   Explore the Mesh, Service, and Workload dashboards     │
echo  │                                                          │
echo  │   PROMETHEUS → http://localhost:9090                      │
echo  │   Try querying: istio_requests_total                     │
echo  │   Or: rate(istio_requests_total[5m])                     │
echo  │                                                          │
echo  │   Traffic is being generated at 10 req/s for 10 min      │
echo  │                                                          │
echo  └──────────────────────────────────────────────────────────┘
echo.

start guide.html

echo  Press any key to stop and clean up...
pause >nul
