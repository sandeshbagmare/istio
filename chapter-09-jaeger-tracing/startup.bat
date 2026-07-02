@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║                                                              ║
echo  ║        ██╗███████╗████████╗██╗ ██████╗                       ║
echo  ║        ██║██╔════╝╚══██╔══╝██║██╔═══██╗                      ║
echo  ║        ██║███████╗   ██║   ██║██║   ██║                      ║
echo  ║        ██║╚════██║   ██║   ██║██║   ██║                      ║
echo  ║        ██║███████║   ██║   ██║╚██████╔╝                      ║
echo  ║        ╚═╝╚══════╝   ╚═╝   ╚═╝ ╚═════╝                      ║
echo  ║                                                              ║
echo  ║     Chapter 9: Distributed Tracing with Jaeger               ║
echo  ║                                                              ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Step 1: Generating Traffic for Trace Data
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [*] Applying traffic generator job...
kubectl apply -f generate-traffic.yaml
echo.
echo  [✓] Traffic generator started! Sending 100 requests to productpage.
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Step 2: Port-Forwarding Jaeger UI
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [*] Setting up port-forward to Jaeger on port 16686...
start /b kubectl port-forward svc/tracing -n istio-system 16686:80 >nul 2>&1
timeout /t 3 >nul
echo  [✓] Jaeger UI port-forward established!
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Step 3: Explore Distributed Traces
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [*] Open Jaeger UI in your browser:
echo.
echo      http://localhost:16686
echo.
echo  [*] How to explore traces:
echo      1. Select 'productpage.default' from the Service dropdown
echo      2. Click 'Find Traces' to see recent traces
echo      3. Click on any trace to see the waterfall span view
echo      4. Explore span details, timing, and tags
echo.
echo  [*] Each trace shows how a single request flows through:
echo      productpage → details → reviews → ratings
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Step 4: Opening Interactive Guide
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [*] Launching guide.html...
start guide.html
echo  [✓] Guide opened in default browser.
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Chapter 9 Lab is Running!
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [i] Jaeger UI:   http://localhost:16686
echo  [i] Traffic is being generated in the background.
echo  [i] Run cleanup.bat when you're done exploring.
echo.

pause
