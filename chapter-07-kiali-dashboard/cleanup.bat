@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║            Chapter 7 Cleanup - Kiali Dashboard                   ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.

echo [1/2] Deleting traffic generator job...
kubectl delete job traffic-generator-kiali --ignore-not-found
echo.

echo [2/2] Stopping Kiali port-forward (port 20001)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :20001 ^| findstr LISTENING') do taskkill /f /pid %%a 2>nul
echo.

echo  ╔═══════════════════════════════════════════════════════════════════╗
echo  ║              Cleanup Complete! Resources removed.                ║
echo  ╚═══════════════════════════════════════════════════════════════════╝
echo.
pause
