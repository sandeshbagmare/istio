@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ██████╗██╗  ██╗ █████╗ ██████╗ ████████╗███████╗██████╗     ███████╗
echo ██╔════╝██║  ██║██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗    ╚════██║
echo ██║     ███████║███████║██████╔╝   ██║   █████╗  ██████╔╝        ██╔╝
echo ██║     ██╔══██║██╔══██║██╔═══╝    ██║   ██╔══╝  ██╔══██╗       ██╔╝
echo ╚██████╗██║  ██║██║  ██║██║        ██║   ███████╗██║  ██║       ██║
echo  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝       ╚═╝
echo.
echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║           Kiali Dashboard - Service Mesh Visualization           ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.

echo [1/4] Deploying traffic generator...
kubectl apply -f generate-traffic.yaml
echo.

echo [2/4] Waiting for traffic to start flowing...
timeout /t 10 >nul
echo.

echo [3/4] Starting Kiali port-forward (port 20001)...
start /b kubectl port-forward svc/kiali -n istio-system 20001:20001
echo.

echo [4/4] Opening guide...
timeout /t 3 >nul
start guide.html
echo.

echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║                     Kiali Dashboard Ready!                       ║
echo  ╠═══════════════════════════════════════════════════════════════════╣
echo  ║                                                                   ║
echo  ║   Open Kiali:  http://localhost:20001                             ║
echo  ║                                                                   ║
echo  ║   Quick Start:                                                    ║
echo  ║   1. Click "Graph" in the left sidebar                            ║
echo  ║   2. Select "default" namespace from the dropdown                 ║
echo  ║   3. Choose "Versioned App Graph" from graph type                 ║
echo  ║   4. Watch live traffic flow between services!                    ║
echo  ║                                                                   ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.
pause
