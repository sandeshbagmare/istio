@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║                                                              ║
echo  ║   Chapter 9 Cleanup: Distributed Tracing with Jaeger         ║
echo  ║                                                              ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Cleaning Up Resources
echo  ══════════════════════════════════════════════════════════════
echo.

echo  [*] Deleting traffic generator job...
kubectl delete -f generate-traffic.yaml --ignore-not-found
echo  [✓] Traffic generator job removed.
echo.

echo  [*] Stopping Jaeger port-forward (port 16686)...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :16686 ^| findstr LISTENING 2^>nul') do taskkill /f /pid %%a >nul 2>&1
echo  [✓] Port-forward stopped.
echo.

echo  ══════════════════════════════════════════════════════════════
echo   Cleanup Complete!
echo  ══════════════════════════════════════════════════════════════
echo.
echo  [✓] All Chapter 9 resources have been cleaned up.
echo  [i] Jaeger is still installed as part of Istio.
echo  [i] Run startup.bat to restart the lab anytime.
echo.

pause
