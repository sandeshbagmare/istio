@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo    ╔══════════════════════════════════════════════════════════════╗
echo    ║          Chapter 8: Cleanup                                  ║
echo    ║          Grafana ^& Prometheus                               ║
echo    ╚══════════════════════════════════════════════════════════════╝
echo.

echo ══════════════════════════════════════════════════════════════
echo  [1/3] Removing Traffic Generator Job...
echo ══════════════════════════════════════════════════════════════
kubectl delete job traffic-generator-metrics --ignore-not-found
echo.

echo ══════════════════════════════════════════════════════════════
echo  [2/3] Killing Grafana port-forward (port 3000)...
echo ══════════════════════════════════════════════════════════════
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo  ✓ Grafana port-forward stopped.
echo.

echo ══════════════════════════════════════════════════════════════
echo  [3/3] Killing Prometheus port-forward (port 9090)...
echo ══════════════════════════════════════════════════════════════
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":9090" ^| findstr "LISTENING"') do (
    taskkill /F /PID %%a >nul 2>&1
)
echo  ✓ Prometheus port-forward stopped.
echo.

echo ══════════════════════════════════════════════════════════════
echo  ✅ Cleanup Complete!
echo ══════════════════════════════════════════════════════════════
echo.
pause
