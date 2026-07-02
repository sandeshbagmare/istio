@echo off
title Chapter 03 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 03 (Traffic Routing)...
kubectl delete virtualservice reviews --ignore-not-found
echo  [OK] Routing rule removed.
echo.
pause
